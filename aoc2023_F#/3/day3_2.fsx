let input = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\3\\day3Input.txt") |> List.ofSeq
let schema = List.map Seq.toList input

let TryParseInt (str:char) =
    match System.Int32.TryParse (string str) with
    | true,int -> Some int
    | _ -> None

let GetIndicesOfStars schema  = 
    let mutable rows = List.length schema
    let mutable cols = List.length schema[0]
    let mutable result = []
    let mutable idx = 0
    for row in [0..rows-1] do
        for col in [0..cols-1] do
            if schema[row][col] = '*' 
            then result <- (row, col) :: result; idx <- idx + 1 
            else idx <- idx + 1
    result

let GetIndicesAroundStar starCoords =
    let (row, col) = starCoords
    [(row-1,col-1);(row-1, col);(row-1,col+1); (row, col-1); (row, col+1); (row+1, col-1); (row+1, col); (row+1, col+1)]

let rec getCoordsWithNumber (schema:char list list) neighbours  =
    match neighbours with
    | [] -> []
    | (row, col)::xs -> match TryParseInt (schema[row][col]) with
                        | Some int -> (row, col) :: getCoordsWithNumber schema xs
                        | None -> getCoordsWithNumber schema xs

let rec trimNeighbours starsAndNeighbours =
    printfn "Input to trim %A" starsAndNeighbours
    match starsAndNeighbours with
    | (row1, col1)::(row2,col2)::xss -> printfn "row1: %A col1: %A row2: %A col2 %A" row1 col1 row2 col2
                                        if row1 = row2 
                                        then (row1,col1) :: trimNeighbours xss 
                                        else (row1, col1) :: (row2, col2) :: trimNeighbours xss
    | [x] -> [x]
    | [] -> []

let rec mem list x =
  match list with
  | [] -> false
  | head :: tail ->
    if x = head then true else mem tail x

let removedupes list1 =
  let rec removeduprec list1 list2 =
    match list1 with
    | [] -> list2
    | head :: tail when mem list2 head = false -> removeduprec tail (head::list2)
    | h::t -> removeduprec t list2
  removeduprec list1 []

       
let findNumberFromCoord (schema:char list list) row col =
    let mutable colIdx = col
    let mutable startIdx = -1
    let mutable endIdx = -1
    let mutable digitCoord = true
    while digitCoord do
        let checker = schema[row][colIdx]
        match TryParseInt checker with
        | Some int -> if colIdx = 0 then startIdx <- colIdx; digitCoord <- false else colIdx <- colIdx - 1
        | None -> startIdx <- colIdx+1;
                  colIdx <- colIdx + 1
                  digitCoord <- false
    digitCoord <- true
    while digitCoord do
        let checker = schema[row][colIdx]
        match TryParseInt checker with
        | Some int -> if colIdx = 139 then endIdx <- colIdx; digitCoord <- false else colIdx <- colIdx + 1 
        | None -> endIdx <- colIdx-1
                  digitCoord <- false
    int (System.String.Concat (schema[row][startIdx..endIdx]))
    

let rec findNumbers (schema:char list list) result coords   = 
    match coords with
    | [] -> result
    | (row:int, col:int) :: xs -> findNumbers schema (findNumberFromCoord schema row col :: result) xs 



let test = "467..114..
...*......
..35..633.
......#...
617*1.....
.....+.58.
..592.....
......755.
...$.*....
.664.598.."

let sch = List.map Seq.toList (List.ofArray (test.Split('\n')))

let findNumbersCurr = findNumbers schema []
let getCoordsCurr = getCoordsWithNumber schema

let FindGears schema starsAndNeighbours =
    let mutable result = []
    for ((starRow, starCol), neighbours) in starsAndNeighbours do
        printfn "Im being iterated now %A" ((starRow, starCol), neighbours)
        let mutable tmp = getCoordsCurr neighbours
        printfn "I am temp: %A" tmp
        if List.length tmp < 2
        then result <- result
        else result <- ((starRow, starCol), findNumbersCurr tmp) :: result
    List.rev result


let starsAndNeighbourCoords = List.rev (List.zip (GetIndicesOfStars schema) (List.map GetIndicesAroundStar (GetIndicesOfStars schema)))
let gearWithNumberPair =  FindGears schema starsAndNeighbourCoords
let numberPairs = List.map (fun (_, numbers) -> numbers) gearWithNumberPair
let hest = List.filter (fun x -> List.length x = 2) (List.map removedupes numberPairs)
//let hest = List.rev <| List.map findNumbersCurr numberPairs

List.sum (List.map (fun [x; y] -> x * y) <| List.filter (fun x -> List.length x <= 2 )hest)


// Virker ikke hvis et gear består af de samme 2 tal f.eks   "....5*5....."