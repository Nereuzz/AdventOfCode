


let (|Int|_|) (str:string) =
    match System.Int32.TryParse str with
    | true,int -> Some int
    | _ -> None


let rec findFirstInt (str:string) =
    match Seq.toList str with
    | [] -> -1
    | s::ss -> match (|Int|_|) <| string s with
               | Some int -> int
               | _ -> findFirstInt <| System.String.Concat ss

let day1_1 str =
    let d1 = findFirstInt str
    let d2 = str |> Seq.rev |> System.String.Concat |> findFirstInt
    int (System.String.Concat([string d1; string d2]))

let input = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\day1Input.txt") |> List.ofSeq
printfn "%d" <| List.sum (List.map day1_1 input)

let rec findStringDigit str rev =
    match str with
    | "one" -> Some 1
    | "two" -> Some 2
    | "three" -> Some 3
    | "four" -> Some 4
    | "five" -> Some 5
    | "six" -> Some 6
    | "seven" -> Some 7
    | "eight" -> Some 8
    | "nine" -> Some 9
    | "" -> None
    | _ -> 
      if rev then findStringDigit str.[0..(Seq.length str - 1)-1] rev else findStringDigit str.[1..] rev

let test3 = "abcone2threexyz"
findStringDigit test3 true
let rec FindDigit (fullStr:string) idx rev =
     let partStr = if rev then fullStr[idx..Seq.length fullStr] else fullStr[0..idx]
     match findStringDigit partStr rev with
     | Some int -> int
     | None -> match (|Int|_|) (if rev then string partStr[0] else string (partStr |> Seq.last))with
               | Some int -> int
               | _ -> let idx = if rev then idx-1 else idx+1
                      FindDigit fullStr idx rev

let day1_2 str =
    let d1 = FindDigit str 0 false
    let d2 = FindDigit str ((Seq.length str) - 1) true
    int (System.String.Concat([string d1; string d2]))

let input2 = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\day1Input.txt") |> List.ofSeq
printfn "%d" <| List.sum (List.map day1_2 input2)