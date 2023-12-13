let input1 = 
    let parsed = 
     System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\6\\input.txt")
     |> List.ofSeq
     |> List.map (fun (x:string) -> x.Split(" "))
     |> List.map (fun x -> x[1..])
     |> List.map (List.ofArray)
     |> List.map (List.filter (fun x -> x <> ""))
     |> List.map (List.map int64)
    List.zip parsed[0] parsed[1]
    
let computeDistance (speed:int64) (timeremaining:int64) = speed * timeremaining

let runRace raceStats =
    let rec loop timeLeft speed record result = 
        match timeLeft with
        | 0L -> result
        | _ -> let distance = computeDistance speed timeLeft
               match distance > record with
               | true -> loop (timeLeft-1L) (speed+1L) record result+1
               | false -> loop (timeLeft-1L) (speed+1L) record result
        
    let (time, record) = raceStats
    loop time 0 record 0

let day6_1 = List.map runRace input1 |> List.fold (fun acc x -> x * acc) 1


let input2 = 
     System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\6\\input.txt")
     |> List.ofSeq
     |> List.map (fun (x:string) -> x.Split(" "))
     |> List.map (fun x -> x[1..])
     |> List.map (List.ofArray)
     |> List.map (List.filter (fun x -> x <> ""))
     |> List.map (System.String.Concat)
     |> List.map int64

let runRace2 time record =
    let rec loop timeLeft speed record result = 
        match timeLeft with
        | 0L -> result
        | _ -> match speed * timeLeft > record with
               | true -> loop (timeLeft-1L) (speed+1L) record (result+1L)
               | false -> loop (timeLeft-1L) (speed+1L) record result
    loop time 0 record 0


let day6_2 = runRace2 input2[0] input2[1]
