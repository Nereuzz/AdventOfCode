


let input = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\3\\day3Input.txt") |> List.ofSeq
let schema = List.map Seq.toList input

let TryParseInt (str:char) =
    match System.Int32.TryParse (string str) with
    | true,int -> Some int
    | _ -> None

let rec FindNumberStartIdx (row:char list) idx =
    if idx = Seq.length row then None else
    match TryParseInt row[idx] with
    | Some int -> Some idx
    | None -> FindNumberStartIdx row (idx+1)

let rec FindNumberEndIdx (row:char list) idx =
    if idx = Seq.length row then Some idx else
    match TryParseInt row[idx] with
    | Some int -> FindNumberEndIdx row (idx+1)
    | None -> Some (idx - 1)

let getNextNumber row initIdx =
    let startIdx = FindNumberStartIdx row initIdx
    match startIdx with
    | Some int -> match FindNumberEndIdx row int with
                       | Some endIdx -> Some (int, endIdx)
                       | None -> None
    | None -> None

let getNumbersForRow row =
    let mutable result = []
    let mutable currentIdx = 0
    while currentIdx < Seq.length row do 
        match getNextNumber row currentIdx with
        | Some (startIdx, endIdx) -> result <- (startIdx, endIdx) :: result;
                                                currentIdx <- endIdx + 1
        | None -> currentIdx <- currentIdx + 1
    List.rev result

let rec indicesToCheck numbers result =
    match numbers with
    | [] -> List.rev result
    | (sid, eid)::xs -> indicesToCheck xs ([sid-1..eid+1] :: result)

let checkForSymbol char =
    match TryParseInt  char with
    | Some _ -> false
    | None -> match char with
              | '*' -> true
              | '+' -> true
              | '$' -> true
              | '#' -> true
              | '=' -> true
              | '-' -> true
              | '&' -> true
              | '%' -> true
              | '/' -> true
              | '@' -> true
              | '.' -> false
              | _ -> printfn "UnknownSumbol: %A" char
                     failwith "comeon.."


(* let rec parseNumbers rows schema rowNr result =
    match rows with
    | [] -> result
    | (startIdx, endIdx)::xs ->  *)



let checkIndices (schema:char list list) ids (value:int*int) rowNr =
    let mutable result = []
    for idx in List.filter (fun x -> x >= 0 && x < 140) ids do
        //printfn "I am idx: %A --- i am row: %A" idx rowNr
        if rowNr = 0 
        then let sameRow = checkForSymbol (schema[rowNr][idx])
             let belowRow = checkForSymbol (schema[rowNr+1][idx])
             if  sameRow || belowRow
             then result <- value :: result
             else result <- result
        elif rowNr = 139
        then let sameRow = checkForSymbol (schema[rowNr][idx])
             let aboveRow = checkForSymbol (schema[rowNr-1][idx])
             if  sameRow || aboveRow
             then result <- value :: result
             else result <- result
        else
        let aboveRow = checkForSymbol (schema[rowNr-1][idx])
        let sameRow = checkForSymbol (schema[rowNr][idx])
        let belowRow = checkForSymbol (schema[rowNr+1][idx])
        if aboveRow || sameRow || belowRow
        then result <- value :: result
        else result <- result
    result


let rec getNumbersToKeep schema result rowNr (row:((int*int) list * int list list)) =
    match row with
    | ([],[]) -> result
    | (n::ns, i::is) -> let fest = (checkIndices schema i n rowNr)
                        match fest with
                        | [] -> getNumbersToKeep schema ( result) rowNr (ns, is)
                        | _ -> getNumbersToKeep schema ( fest :: result) rowNr (ns, is)
let getNumbersToKeepCurried = getNumbersToKeep schema []

let parseNumbers (schema:char list list) rowNr rowResult =
    let mutable result = []
    for (startIdx, endIdx) in rowResult do
     let test = schema[rowNr][startIdx..endIdx]
     result <- int (System.String.Concat test) :: result
    result

let parseNumbersCurr = parseNumbers schema

let day3_1 =
  let numbersAndIndices = List.zip (List.map getNumbersForRow schema) (List.foldBack (fun item acc ->  indicesToCheck item [] :: acc) (List.map getNumbersForRow schema) [])
  printfn "%A" numbersAndIndices[14]
  let numbersToParse = List.map List.concat (List.map2 getNumbersToKeepCurried [0..139] numbersAndIndices)
  List.sum <| List.concat (List.map2 parseNumbersCurr [0..139] numbersToParse)
day3_1


//printfn "%A" day3_1
//let tmp = List.rev <| getNumbersToKeep numbersAndIndices schema
//let tmp2 = List.fold2 (fun acc result rowNr -> parseNumbers result rowNr :: acc) [] tmp [0..9]
