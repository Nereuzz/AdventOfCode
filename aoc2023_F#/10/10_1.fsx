open System.IO;

type Pipe = 
 | Lodret of int*int 
 | Vandret of int*int
 | L of int*int
 | J of int*int
 | Syv of int*int
 | F of int*int
 | Ground of int*int
 | S of int*int


let GetPipe pipe coords  =
    match pipe with
    | '|' -> Lodret coords
    | '-' -> Vandret coords
    | 'L' -> L coords
    | 'J' -> J coords
    | '7' -> Syv coords
    | 'F' -> F coords
    | '.' -> Ground coords
    | 'S' -> S coords
    | _ -> printfn "I am pipe: %A" pipe; failwith "niksen du"

let readGraph graph x y = 
    try
      Some (Array2D.get graph x y)
    with
     | :? System.ArgumentException -> None
     | :? System.IndexOutOfRangeException -> None

let GetEdges (graph:Pipe array2d) pipe =
    let r = readGraph graph
    match pipe with
    | Lodret (x,y) -> (Lodret (x,y), [r (x-1) y;r (x+1) y])
    | Vandret (x,y) -> (Vandret (x,y), [r x (y-1);r x (y+1)])
    | L (x,y) -> (L (x,y), [r x (y+1);r (x-1) y])
    | J (x,y) -> (J (x,y), [r x (y-1);r (x-1) y])
    | Syv (x,y) -> (Syv (x,y), [r (x+1) y; r x (y-1)])
    | F (x,y) -> (F (x,y), [r (x+1) y;r x (y+1)])
    | Ground (x,y)-> (Ground (x,y), [])
    | S (x,y) ->  (S (x,y), [])




let AddPipe row col  pipe =
    GetPipe pipe (row,col)

let ParseGrid (grid:char array2d)  =
    let graph = Array2D.mapi (fun row col char -> AddPipe row col char) grid
    Array2D.map (fun pipe -> GetEdges graph pipe) graph
    |> Seq.cast<Pipe * Pipe option list> 
    |> Seq.toList
    |> Map.ofList
    |> Map.map (fun k v -> List.filter (fun x -> x <> None) v)
    |> Map.map (fun _ v -> List.map Option.get v)
    |> Map.map (fun _ v -> List.sort v)

let ParseGridArray2D (grid:char array2d)  =
    let graph = Array2D.mapi (fun row col char -> AddPipe row col char) grid
    Array2D.map (fun pipe -> GetEdges graph pipe) graph
    

let input = 
  File.ReadAllLines "aoc2023_F#/10/input.txt" 
  |> Array.map (fun x -> Seq.toList x) 
  |> List.ofArray
  |> array2D

let rec HasStartInEdges pipe edges = 
    match edges with
    | [] -> None
    | x::xs -> match x with
               | S (r,c) -> Some pipe
               | _ -> HasStartInEdges pipe xs

let dfs graph =
    let rec loop visited pipes path =
     match pipes with
     | [] -> path
     | p::ps -> if List.contains p visited 
                then loop visited ps path
                else loop (p::visited) ((Map.find p graph)@ps) (p::path)
    let start = Map.pick (fun x y -> HasStartInEdges x y) graph
    loop [] [start] []

let day10_1 = ParseGrid >> dfs >> List.length
printfn "Day 10 part 1: %A" ((day10_1 input)/2)

let rec RemoveAllNonLoopPipes loop graph =
    let helper row col c =
     if List.contains (GetPipe c (row, col)) loop 
     then c
     else '.'

    Array2D.mapi helper graph
let ReplaceStartWithPipe (start:Pipe) graph = 
    // Only works for my input.. Took shortest path and analyzed by eyes
    match start with
    | S (row, col) -> Array2D.set graph row col 'F'; graph
    | _ -> failwith "Startpipe was not given as argument"
    

let rec FilterFest row col pipe inside =
    match pipe with
    | Ground (r,c) -> (inside, inside)
    | L (r,c) | Lodret (r,c) | J (r,c) -> (not inside, false)
    | _ -> (inside, false)

let r (pipe:Pipe) = 
    match pipe with
    | Lodret (x,y) -> (x,y)
    | Vandret (x,y) -> (x,y)
    | L (x,y) -> (x,y)
    | J (x,y) -> (x,y)
    | Syv (x,y) -> (x,y)
    | F (x,y) -> (x,y)
    | Ground (x,y) -> (x,y)
    | S (x,y) -> (x,y)

let rec EvenOddRule graph inside finalResult =
    match graph with
    | [] -> finalResult
    | p::xs -> let (r,c) = r p
               let (newInside, result) = FilterFest r c p inside in
                                            if result
                                            then EvenOddRule xs newInside (p::finalResult)
                                            else EvenOddRule xs newInside finalResult


let day2_2 =
    let loop = input |> ParseGrid |> dfs
    let startPipe = List.head loop
    let updatedMap = input |> RemoveAllNonLoopPipes loop |> ReplaceStartWithPipe startPipe |> ParseGridArray2D
    let hehe = 
     List.collect id [for x in 0 .. Array2D.length1 updatedMap - 1 ->
                      [ for y in 0 .. Array2D.length2 updatedMap - 1 -> updatedMap.[x, y] ]
                     ] 
     |> List.map (fun x -> fst x)
    EvenOddRule hehe false [] |> List.length

printfn "Dau 10 part 2: %A" day2_2