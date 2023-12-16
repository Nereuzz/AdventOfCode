open System.IO;

let input =
 File.ReadAllLines "16/test.txt"
 |> array2D
 |> Array2D.map (fun x -> (x,0))


let MoveUp row col = (row-1,col)
let MoveDown row col = (row+1,col)
let MoveLeft row col = (row, col-1)
let MoveRight row col = (row, col+1)

let rec DrawBeam array direction row col queue =
    
    if (row,col) = (0,0)
    then let (tile, count) = array.[row,col]
         Array2D.set array row col (tile,count+1)
         DrawBeam array MoveRight row col queue
    else
    let (newRow,newCol) = direction row col
    match array[newRow,newCol] with
    | '.' -> Array2D.set array newRow newCol 
             DrawBeam array direction newRow newCol queue
    | '/' -> 
     
