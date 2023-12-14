open System.IO;


type MapItem =
   | R
   | SR
   | E

let ParseMap map =
    let rec runCols row result =
        match row with
        | [] -> result |> List.rev
        | x::xs -> match x with
                   | 'O' -> runCols xs (R::result)
                   | '#' -> runCols xs (SR::result)
                   | '.' -> runCols xs (E::result)
                   | _ -> failwith "Illegal map char"
    
    let rec runRows map result =
        match map with
        | [] -> result |> List.rev
        | x::xs -> runRows xs ((runCols x []) :: result)
    runRows map []
    

let input =
    File.ReadAllLines "14/input.txt"
    |> Array.map (fun x -> Seq.toList x)
    |> List.ofArray
    |> ParseMap

let rec DoneRolling row =
    match row with
    | [] -> true
    | R::R::xs -> DoneRolling (xs)
    | R::E::xs -> DoneRolling (E::xs)
    | E::R::_ -> false
    | E::E::xs -> DoneRolling (E::xs)
    | E::SR::xs -> DoneRolling (SR::xs)
    | _::xs -> DoneRolling xs

let rec MoveRocksLeft row =
    let rec TiltLeft row =
     match row with
     | [] -> []
     | x::[] -> x::TiltLeft []
     | x::xs::xss -> if x = E && xs = R
                     then xs::x::TiltLeft xss
                     else x::TiltLeft (xs::xss)

    match TiltLeft row with
    | xs -> if DoneRolling xs
            then xs
            else MoveRocksLeft xs

let ComputeLoad totalRows row col i =
    match i with
    | R -> totalRows - row
    | _ -> 0

let day14_1 = 
    let map = input |> List.transpose |> List.map MoveRocksLeft |> List.transpose |> array2D
    let ComputedLoadForMap = ComputeLoad (Array2D.length2 map)
    Array2D.mapi ComputedLoadForMap map
    |> Seq.cast<int> 
    |> Seq.sum

day14_1 |> printfn "day 14 part 1: %d"

let cycle input =
 input
 // Move north
|> List.transpose
|> List.map MoveRocksLeft
|> List.transpose
// Move west
|> List.map MoveRocksLeft
// Move South
|> List.rev
|> List.transpose
|> List.map MoveRocksLeft
|> List.transpose
|> List.rev
// Move East
|> List.map List.rev
|> List.map MoveRocksLeft
|> List.map List.rev

let rec cycleMap map times =
    match times with
    | x when x > 0 -> cycleMap (cycle map) (times-1)
    | _ -> map
  

let map = input |> array2D
let ComputedLoadForMap = ComputeLoad (Array2D.length2 map)

let rec day14_2 map states cycles actualCycles= 
    match cycles with
    | x when x > 0 -> let newMap = cycle map
                      if Map.containsKey newMap states
                      then let size = (Map.find newMap states) - cycles
                           let start = Map.find newMap states
                           let initCycleCount = Map.values states |> Seq.cast |> Seq.max
                           let step = (actualCycles - (initCycleCount-start+1)) % size
                           cycleMap newMap step
                           |> array2D 
                           |> Array2D.mapi ComputedLoadForMap
                           |> Seq.cast<int> 
                           |> Seq.sum 
                      else day14_2 newMap (Map.add newMap cycles states) (cycles-1) actualCycles
    | _ -> failwith "Damn, no cycle.."

day14_2 input Map.empty 1000 1000000000 |> printfn "Day 14 part 2: %A"
