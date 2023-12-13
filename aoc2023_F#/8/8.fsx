open System.IO

let data = 
 File.ReadLines "aoc2023_F#\\8\\input.txt"
 |> List.ofSeq

let getMap (input:string list) =
    let steps = input.[0] |> List.ofSeq
    let rest = input[2..]
    let maps = 
      rest 
      |> List.map (fun x -> x.Split(" = "))
      |> List.map (fun x -> (x.[0], x.[1].Split(", ")))
      |> List.map (fun (steps, maps) -> (steps, Array.map (fun (s:string) -> s.Replace("(", "")) maps))
      |> List.map (fun (steps, maps) -> (steps, Array.map (fun (s:string) -> s.Replace(")", "")) maps))
      |> List.map (fun (steps, maps) -> (steps, List.ofArray maps))
      |> List.map (fun (steps, maps) -> (steps, ((maps[0],maps[1]))))
    (steps, maps)

let day8_1 input startingPos =
    let resetSteps = 
        let (steps, maps) = getMap input
        steps

    let rec walk steps maps (position:string) counter resetSteps =
     match position with
     | x when x.EndsWith("Z") -> counter
     | _ -> 
      match steps with
      | [] -> walk (resetSteps) maps position counter resetSteps
      | x :: xs -> match x with
                   | 'R' -> let newPosition = Map.tryFind position maps |> Option.get |> snd 
                            walk xs maps newPosition (counter+1) resetSteps
                   | 'L' -> let newPosition = Map.tryFind position maps |> Option.get |> fst
                            walk xs maps newPosition (counter+1) resetSteps
    let (steps, maps) = getMap input
    let mappedMaps = Map(maps)
    printfn "%A" <| mappedMaps
    walk steps mappedMaps startingPos 0 resetSteps

(* day8_1 data "AAA" |> printfn "Day 8 part 1: %A" *)

let rec gcd a b = 
            match (a,b) with
            | (x,y) when x = y -> x
            | (x,y) when x > y -> gcd (x-y) y
            | (x,y) -> gcd x (y-x)

let lcm a b = a*b/(gcd a b)

let day8_2 input =
    let (_, maps) = getMap input
    let startingPositions = List.filter (fun ((pos:string),(l,r)) -> pos.EndsWith("A")) maps |> List.map fst
    let ehm = (day8_1 input)
    let hest = List.map ehm startingPositions |> List.sort 
    lcm (lcm (lcm (lcm (lcm hest.[0] hest.[1]) hest.[2]) hest[3]) hest[4]) hest[5] // OR just put the numbers into an online LCM calculator..

day8_2 data