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
    File.ReadAllLines "aoc2023_F#/14/test.txt"
    |> Array.map (fun x -> Seq.toList x)
    |> List.ofArray
    |> ParseMap
    |> List.transpose

let rec DoneRolling row tmp =
    match row with
    | [] -> true
    | x::xs -> if x = R
               then DoneRolling xs true
               else false

let rec MoveRocksLeft row =
    printfn "Rolling..%A" row
    let rec TiltLeft row =
     match row with
     | [] -> []
     | x::[] -> x::TiltLeft []
     | x::xs::xss -> if x = E && xs = R
                     then xs::x::TiltLeft xss
                     else x::TiltLeft (xs::xss)

    match TiltLeft row with
    | xs -> if DoneRolling xs true
                           then xs
                           else printfn "Rerolling..%A" xs; MoveRocksLeft xs
                           
input
List.map MoveRocksLeft input