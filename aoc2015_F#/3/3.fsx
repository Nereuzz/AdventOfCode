open System.IO

let data = File.ReadAllText "aoc2015_F#\\3\\input.txt"

let updatePosition char x y =
    match char with
    | '>' -> x+1,y
    | '<' -> (x-1,y)
    | '^' -> (x,y+1)
    | 'v' -> (x, y-1)
    | _ -> failwith "Not possible char"

let rec solve position result chars  =
    let (x,y) = position
    match chars with
    | [] -> result
    | c::cs -> let newPosition = updatePosition c x y
               solve newPosition (newPosition::result) cs

data
 |> List.ofSeq
 |> solve (0,0) [(0,0)]
 |> List.distinct
 |> List.length

let rec solve2 santaPos roboPos result santaFlag chars = 
    match chars with
    | [] -> result
    | c::cs when santaFlag -> let (x,y) = santaPos
                              let newPosition = updatePosition c x y
                              solve2 newPosition roboPos (newPosition::result) (not santaFlag) cs
    | c::cs -> let (x,y) = roboPos
               let newPosition = updatePosition c x y
               solve2 santaPos newPosition (newPosition::result) (not santaFlag) cs 

data
 |> List.ofSeq
 |> solve2 (0,0) (0,0) [(0,0)] true
 |> List.distinct
 |> List.length