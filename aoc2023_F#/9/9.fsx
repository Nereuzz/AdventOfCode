open System.IO;

let data = File.ReadAllLines "./9/input.txt"

let parseInput data =
    data 
    |> Array.map (fun (x:string) -> x.Split(" "))
    |> Array.map List.ofArray
    |> List.ofArray
    |> List.map (fun x -> List.map int x)


let allZero list = List.forall (fun x -> x = 0) list
let rec getDistances sequence =
    let rec loop (list:int list) result steps =
        match list with
        | [] -> result :: steps
        | [x] -> if allZero result 
                      then List.rev result :: steps 
                      else loop (List.rev result) [] (List.rev result :: steps)
        | x::xs -> loop xs (List.head xs - x::result) (steps)
    loop sequence [] [sequence]

let day9_1 = 
      data 
      |> parseInput
      |> List.map getDistances
      |> List.map (List.map List.last)
      |> List.map (List.sum)
      |> List.sum

let day9_2 =
       data 
       |> parseInput
       |> List.map getDistances
       |> List.map (List.map List.head)
       |> List.map (List.fold (fun acc x -> x - acc) 0)
       |> List.sum
      
    
day9_1 |> printfn "Day 9 part one: %A"
day9_2 |> printfn "Day 9 part two: %A"