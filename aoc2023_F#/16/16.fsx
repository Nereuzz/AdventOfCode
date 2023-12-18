open System.IO;

let readInput =
 File.ReadAllLines "aoc2023_F#/16/input.txt"
 |> array2D
 |> Array2D.map (fun x -> (x,0))

type Direction =
    | MoveUp of int*int
    | MoveDown of int*int
    | MoveLeft of int*int
    | MoveRight of int*int

let MoveUp row col = MoveUp (row-1,col)
let MoveDown row col = MoveDown (row+1,col)
let MoveLeft row col = MoveLeft (row, col-1)
let MoveRight row col = MoveRight (row, col+1)

let GetCoords direction =
    match direction with
    | MoveUp (x,y) -> (x,y)
    | MoveDown (x,y) -> (x,y)
    | MoveLeft (x,y) -> (x,y)
    | MoveRight (x,y) -> (x,y)

let rec DrawBeam (array:(char*int) array2d) direction row col queue =
    let nextTile = direction row col
    let (newRow, newCol) = GetCoords nextTile
    if row < 0 || row >= Array2D.length1 array || col < 0 || col >= Array2D.length2 array
    then if List.length queue = 0 && (row,col) <> (0,0)
         then array
         else match queue with
              | (dir, (r, c))::xs -> DrawBeam array dir r c xs
              | _ -> failwith "you fucked up"
    else
    match array[row,col] with
    | ('.',count) | ('#',count) -> 
                     Array2D.set array row col ('#',count+1)
                     DrawBeam array direction newRow newCol queue
    | ('/',count) -> 
                     
                     match nextTile with
                     | MoveUp _    -> Array2D.set array row col ('/',count+1)
                                      let (newRow,newCol) = MoveRight row col|> GetCoords
                                      DrawBeam array MoveRight newRow newCol queue

                     | MoveDown _  -> Array2D.set array row col ('/',count+1)
                                      let (newRow,newCol) = MoveLeft row col |> GetCoords
                                      DrawBeam array MoveLeft newRow newCol queue

                     | MoveLeft _  -> Array2D.set array row col ('/',count+1)
                                      let (newRow,newCol: int) = MoveDown row col |> GetCoords
                                      DrawBeam array MoveDown newRow newCol queue

                     | MoveRight _ -> Array2D.set array row col ('/',count+1)
                                      let (newRow,newCol: int) = MoveUp row col |> GetCoords
                                      DrawBeam array MoveUp newRow newCol queue
    | ('\\',count) ->
                      match nextTile with
                      | MoveUp _    -> Array2D.set array row col ('\\',count+1)
                                       let (newRow,newCol) = MoveLeft row col |> GetCoords
                                       DrawBeam array MoveLeft newRow newCol queue

                      | MoveDown _  -> Array2D.set array row col ('\\',count+1)
                                       let (newRow,newCol) = MoveRight row col |> GetCoords
                                       DrawBeam array MoveRight newRow newCol queue

                      | MoveLeft _  -> Array2D.set array row col ('\\',count+1)
                                       let (newRow,newCol) = MoveUp row col |> GetCoords
                                       DrawBeam array MoveUp newRow newCol queue

                      | MoveRight _ -> Array2D.set array row col ('\\',count+1)
                                       let (newRow,newCol) = MoveDown row col |> GetCoords
                                       DrawBeam array MoveDown newRow newCol queue
    | ('|',count) -> 
                     match nextTile with
                     | MoveUp _   -> Array2D.set array row col ('|',count+1)
                                     DrawBeam array direction newRow newCol queue

                     | MoveDown _  -> Array2D.set array row col ('|',count+1)
                                      DrawBeam array direction newRow newCol queue

                     | MoveLeft _  -> if count > 0
                                      then DrawBeam array MoveUp -1 -1 queue
                                      else 
                                      Array2D.set array row col ('|',count+1)
                                      let (newRowUp,newColUp) = MoveUp row col |> GetCoords
                                      let (newRowDown,newColDown) = MoveDown row col |> GetCoords
                                      DrawBeam array MoveUp newRowUp newColUp ((MoveDown, (newRowDown, newColDown))::queue)

                     | MoveRight _ -> if count > 0
                                      then DrawBeam array MoveUp -1 -1 queue
                                      else 
                                      Array2D.set array row col ('|',count+1)
                                      let (newRowUp,newColUp) = MoveUp row col |> GetCoords
                                      let (newRowDown,newColDown) = MoveDown row col |> GetCoords
                                      DrawBeam array MoveUp newRowUp newColUp ((MoveDown, (newRowDown, newColDown))::queue)

    | ('-',count) -> 
                     match nextTile with
                     | MoveUp _    -> if count > 0
                                       then DrawBeam array MoveUp -1 -1 queue
                                      else
                                      Array2D.set array row col ('-',count+1)
                                      let (newRowLeft,newColLeft) = MoveLeft row col |> GetCoords
                                      let (newRowRight,newColRight) = MoveRight row col |> GetCoords
                                      DrawBeam array MoveLeft newRowLeft newColLeft ((MoveRight, (newRowRight, newColRight))::queue)

                     | MoveDown _  -> if count > 0
                                      then DrawBeam array MoveUp -1 -1 queue
                                      else
                                      Array2D.set array row col ('-',count+1)
                                      let (newRowLeft,newColLeft) = MoveLeft row col |> GetCoords
                                      let (newRowRight,newColRight) = MoveRight row col |> GetCoords
                                      DrawBeam array MoveLeft newRowLeft newColLeft ((MoveRight, (newRowRight, newColRight))::queue)

                     | MoveLeft _  -> Array2D.set array row col ('-',count+1)
                                      DrawBeam array direction newRow newCol queue

                     | MoveRight _ -> Array2D.set array row col ('-',count+1)
                                      DrawBeam array direction newRow newCol queue
    | _ -> failwith "Illegal character in map"

let day16_1 input = 
    DrawBeam input MoveRight 0 0 []
    |> Array2D.map (fun x -> snd x)
    |> Seq.cast<int> 
    |> Seq.filter (fun x -> x > 0)
    |> Seq.length

day16_1 readInput |> printfn "Day 16 part 1: %A"

let day16_2 =
    let startCoords =
        [ for i in 0..(Array2D.length2 readInput) - 1 -> (MoveDown, (0,i)) ] @
        [ for i in 0..(Array2D.length2 readInput) - 1 -> (MoveUp, ((Array2D.length1 readInput) - 1, i))] @
        [ for i in 0..(Array2D.length1 readInput) - 1 -> (MoveRight, (i, 0))] @
        [ for i in 0..(Array2D.length2 readInput) - 1 -> (MoveLeft, (i, (Array2D.length1 readInput) - 1))]
    let states = [for i in 1..(List.length startCoords) -> Array2D.copy readInput]
    List.map2 (fun x y -> DrawBeam y (fst x) (fst(snd(x))) (snd(snd(x))) []) startCoords states
    |> List.map (fun x -> Array2D.map (fun y -> snd y) x) 
    |> List.map Seq.cast<int>
    |> List.map (Seq.filter (fun x -> x > 0))
    |> List.map (Seq.length)
    |> List.max