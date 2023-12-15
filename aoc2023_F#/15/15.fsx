open System.IO;

let input = 
 let string = File.ReadAllText "aoc2023_F#/15/input.txt"
 string.Split(',')
 |> List.ofSeq
 
 
let GetAsciiValue res (c:char)  = (int c + res)

let Times17 a = a * 17
let Mod256 a = a % 256

let HASH res =  GetAsciiValue res >> Times17 >> Mod256

let RunHASH string =
    let rec loop chars result =
        match chars with
        | [] -> result
        | x::xs -> loop xs (HASH result x)
    loop (List.ofSeq string) 0

let day15_1 = List.map RunHASH input |> List.sum |> printfn "Day 15 part 1: %A"


let LabelInBox (box:((string*int)list)) label =
    let rec loop box index =
        match box with
        | [] -> -1
        | (lab,len)::xs when lab = label -> index
        | (lab,len)::xs -> loop xs (index+1)
    loop box 0

let InsertLabel (box:(string * int) list) label length index =
    List.removeAt index box |> List.insertAt index (label,length)

let RemoveLabel (box:(string * int) list)  index =
    List.removeAt index box 

let EqualOperation boxes boxNr (label:string) (length:int) =
    let boxContents = Map.find boxNr boxes
    let labelIndex = LabelInBox boxContents label 
    if (labelIndex >= 0)
    then let newBoxContents = InsertLabel boxContents label length labelIndex
         Map.add boxNr newBoxContents boxes
    else Map.add boxNr (boxContents @ [(label,length)]) boxes

let DashOperation boxes boxNr label =
    let boxContents = Map.find boxNr boxes
    let labelIndex = LabelInBox boxContents label 
    if (labelIndex >= 0)
    then let newBoxContents = RemoveLabel boxContents labelIndex
         Map.add boxNr newBoxContents boxes
    else boxes
    
let rec BuildBoxMap (boxMap) boxes =
    match boxes with
    | x when x >= 0 -> BuildBoxMap (Map.add (boxes) ([]:(string* int) list ) boxMap) (boxes-1)
    | _ -> boxMap

let rec RunLenseFixer boxes (strings:string list) =
    match strings with
    | [] -> boxes
    | x::xs -> if x.EndsWith('-')
               then let label = x.Replace("-", "")
                    let boxNr = RunHASH label
                    let newBoxes = DashOperation boxes boxNr label
                    RunLenseFixer newBoxes xs
               else match x.Split("=") |> List.ofArray with
                    | [label;len] ->
                      let boxNr = RunHASH label
                      let newBoxes = EqualOperation boxes boxNr label (int len)
                      RunLenseFixer newBoxes xs
                    | _ -> failwith "Not possible"
                

let ComputePower box =
    match box with
    | (nr, lenses) -> 
      List.fold2 (fun acc len slot -> acc + ((1 + nr) * len * slot)) 0 (List.map snd lenses) [1..List.length lenses]
    
let day15_2 =
 RunLenseFixer (BuildBoxMap Map.empty 255 ) input 
 |> Map.fold (fun x key value -> x@[(key,value)]) []
 |> List.filter (fun x -> snd x <> List.empty) 
 |> List.map ComputePower
 |> List.sum

day15_2 |> printfn "Day 15 part 1: %A"
