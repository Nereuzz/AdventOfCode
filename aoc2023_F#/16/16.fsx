open System.IO;

let input =
 File.ReadAllLines "16/test.txt"
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
    if (row,col) = (0,0)
    then let (tile, count) = array.[row,col]
         Array2D.set array row col (tile,count+1)
         DrawBeam array MoveRight row col queue
    else
    let nextTile = direction row col
    let (newRow, newCol) = GetCoords nextTile
    match array[newRow,newCol] with
    | ('.',count) -> Array2D.set array newRow newCol ('.',count+1)
                     DrawBeam array direction newRow newCol queue
    | ('/',count) -> match nextTile with
                     | MoveUp _ -> Array2D.set array newRow newCol ('/',count+1)
                                   DrawBeam array MoveRight newRow newCol queue
                     | MoveDown _ -> Array2D.set array newRow newCol ('/',count+1)
                                     DrawBeam array MoveLeft newRow newCol queue
                     | MoveLeft _ -> Array2D.set array newRow newCol ('/',count+1)
                                     DrawBeam array MoveUp newRow newCol queue
                     | MoveRight _ -> Array2D.set array newRow newCol ('/',count+1)
                                      DrawBeam array MoveDown newRow newCol queue
    | ('\\',count) -> match nextTile with
                      | MoveUp _ -> Array2D.set array newRow newCol ('\\',count+1)
                                    DrawBeam array MoveLeft newRow newCol queue
                      | MoveDown _ -> Array2D.set array newRow newCol ('\\',count+1)
                                      DrawBeam array MoveRight newRow newCol queue
                      | MoveLeft _ -> Array2D.set array newRow newCol ('\\',count+1)
                                      DrawBeam array MoveDown newRow newCol queue
                      | MoveRight _ -> Array2D.set array newRow newCol ('\\',count+1)
                                       DrawBeam array MoveUp newRow newCol queue
    | ('|',count) -> match nextTile with
                     | MoveUp _ -> Array2D.set array newRow newCol ('|',count+1)
                                   DrawBeam array direction newRow newCol queue
                     | MoveDown _ -> Array2D.set array newRow newCol ('|',count+1)
                                     DrawBeam array MoveRight newRow newCol queue
                     | MoveLeft _ -> Array2D.set array newRow newCol ('|',count+1)
                                     DrawBeam array MoveUp newRow newCol (((MoveDown), (newRow, newCol))::queue)
                     | MoveRight _ -> Array2D.set array newRow newCol ('|',count+1)
                                      DrawBeam array MoveUp newRow newCol (((MoveDown), (newRow, newCol))::queue)
    | ('-',count) -> match nextTile with
                     | MoveUp _ -> Array2D.set array newRow newCol ('-',count+1)
                                   DrawBeam array MoveLeft newRow newCol (((MoveRight), (newRow, newCol))::queue)
                     | MoveDown _ -> Array2D.set array newRow newCol ('-',count+1)
                                     DrawBeam array MoveLeft newRow newCol (((MoveRight), (newRow, newCol))::queue)
                     | MoveLeft _ -> Array2D.set array newRow newCol ('-',count+1)
                                     DrawBeam array direction newRow newCol queue
                     | MoveRight _ -> Array2D.set array newRow newCol ('-',count+1)
                                      DrawBeam array direction newRow newCol queue
    | _ -> failwith "Illegal character in map"
     
DrawBeam input MoveRight 0 0