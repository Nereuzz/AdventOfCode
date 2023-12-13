let test1 = "Game 11: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
let test2 = "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue"
let test3 = "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red"
let test4 = "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red"
let test5 = "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"


let testList = [test1; test2; test3; test4; test5]

type Game = int * int list

let getColor color =
    match color with
    | "red" -> 0
    | "green" -> 1
    | "blue" -> 2
    | _ -> failwith "unknown color: %A" <| color


let readDice  (config:string)  =
    match config.Split "," |> List.ofArray with
    | [x] -> let tmp = x.Trim().Split " " in
                      let color = getColor tmp[1]
                      let value = int tmp[0]
                      [(color, value)]
    | [x; y] -> let tmp = x.Trim().Split " " in                
                                 let color = getColor tmp[1]
                                 let value = int tmp[0]
                                 let tmp1 = y.Trim().Split " "
                                 let color1 = getColor tmp1[1]
                                 let value1 = int tmp1[0]
                                 [(color, value); (color1, value1)]
    | [x; y; z] -> let tmp = x.Trim().Split " " in
                                 let color = getColor tmp[1]
                                 let value = int tmp[0]
                                 let tmp1 = y.Trim().Split " "
                                 let color1 = getColor tmp1[1]
                                 let value1 = int tmp1[0]
                                 let tmp2 = z.Trim().Split " "
                                 let color2 = getColor tmp2[1]
                                 let value2 = int tmp2[0]
                                 [(color, value); (color1, value1); (color2, value2)]
    | _ -> failwith "Unknown hehe"

let rec getCounts items color res =
    match items with
    | [] -> res
    | x::xs -> match x with
               | (colorr, count) when color = colorr -> 
               if count > res 
               then getCounts xs color count 
               else getCounts xs color res
               | _ -> getCounts xs color res

let loadGame (input:string) =
    let gameId = let gamePart = input.Trim().Split " " 
                    in gamePart[1].Replace(':', ' ')
    let draws = let tmp = input.Split ":" 
                     in let draws = tmp[1].Split ";" |> List.ofArray
                        in List.map readDice draws |> List.collect id
    Game (int( gameId),[getCounts draws 0 0; getCounts draws 1 0; getCounts draws 2 0])


let isPossible (result:Game) = 
    match result with
    | (id, [red; green; blue]) -> if red > 12 || green > 13 || blue > 14 then 0 else id
    | _ -> failwith "unknown"

printfn "%A" <| loadGame test1

let lowestConfig (result:Game) =
    match result with
    | (id, [red; green; blue]) -> green * red * blue
    | _ -> failwith "unknown"

let input = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\2\\day2_input.txt") |> List.ofSeq
let day2_1 = List.map loadGame >> List.map isPossible >> List.sum
day2_1 input |> printfn "2.1: %A"

let day2_2 = List.map loadGame >> List.map lowestConfig >> List.sum
day2_2 input |> printfn "2.2: %A"