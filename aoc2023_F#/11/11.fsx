open System.IO;


let int2char x = char (x+48)
let char2int x = int x - 48
let image = 
  File.ReadAllLines "aoc2023_F#/11/input.txt" 
  |> Array.map (fun x -> Seq.toList x) 
  |> List.ofArray

let rec FindEmptyRows image emptyRows =
    match image with
    | [] -> emptyRows
    | (idx, xs)::ps -> if List.distinct xs = ['.']
                       then FindEmptyRows ps (idx::emptyRows)
                       else FindEmptyRows ps emptyRows

let AddEmptyRow  rowIdxs image =
    let rec insertRow image idxs result newRow =
     match image with
     | [] -> result
     | (rowIdx, xs)::ps when List.contains (rowIdx) idxs -> insertRow ps idxs (xs::newRow::result) newRow
     | (_, xs)::ps -> insertRow ps idxs (xs::result) newRow
    let newRow = [for i in 1..List.length (List.head image) -> '.']
    insertRow (List.indexed image) rowIdxs [] newRow |> List.rev
    

let ExpandUnivers image =
    let emptyRows = FindEmptyRows (List.indexed image) []
    let emptyCols = FindEmptyRows (List.indexed (List.transpose image)) []
    let Expand = List.transpose >> AddEmptyRow emptyCols >> List.transpose >> AddEmptyRow emptyRows
    Expand image

let EnumerateGalaxies image =
    let rec helperImage image galaxyNumber result rowResult =
     match image with
     | [] -> List.rev result
     | xs::xss -> match xs with
                  | [] -> helperImage xss galaxyNumber (List.rev rowResult::result) []
                  | c::cs when c = '#' -> helperImage (cs::xss) (galaxyNumber+1) result (int2char galaxyNumber::rowResult)
                  | c::cs -> helperImage (cs::xss) galaxyNumber result (c::rowResult)
    helperImage image 0 [] []

let CheckForGalaxy row col y =
    match y with
    | c when c <> '.' -> Some (c, (row,col))
    | _ -> None

let GetGalaxyCoords (image:char list list) =
   image 
   |> List.mapi (fun row x -> List.mapi (fun col y -> CheckForGalaxy row col y) x) 
   |> List.concat
   |> List.filter Option.isSome
   |> List.map Option.get

let GetGalaxyPairs galaxyList =
    let rec removeDups result pairs  =
        match pairs with
        | [] -> result |> List.rev
        | x::xs -> if List.contains (snd x, fst x) result
                   then removeDups result xs
                   else removeDups (x::result) xs

    List.allPairs galaxyList galaxyList
    |> List.filter (fun x -> fst x <> snd x)


        
let day11_1 = // There was no reason to expand the image.. Just use math.. See part 2
     image 
     (* |> ExpandUnivers *)
     |> EnumerateGalaxies 
     |> GetGalaxyCoords
     |> List.map snd
     |> GetGalaxyPairs
     |> List.map (fun x -> 
                   let source = fst x
                   let desti = snd x
                   let distance = abs ((fst desti) - (fst source)) + abs ((snd desti) - (snd source))
                   distance
                   )
     |> List.sum

let Distance emptyRowIdxs emptyCols factor  (source:int*int) (destination:int*int)=
    let addRows (distance:int64) =
        match List.countBy (fun x -> (x >= fst source && x <= fst destination) ||
                                       (x <= fst source && x >= fst destination) ) emptyRowIdxs with
        | [] -> distance
        | [(true, count)] -> distance + factor * int64 count
        | [(false, _)] -> distance
        | [(true,count);(_,_)] -> distance + factor * int64 count
        | [(_,_);(true,count)] -> distance + factor * int64 count
        | _ -> failwith "Not possible.."

    let addCols distance = 
        match List.countBy (fun x -> (x >= snd source && x <= snd destination) ||
                                              (x <= snd source && x >= snd destination) ) emptyCols with
        | [] -> distance
        | [(true, count)] -> distance + factor * int64 count
        | [(false, _)] -> distance
        | [(true,count);(_,_)] -> distance + factor * int64 count
        | [(_,_);(true,count)] -> distance + factor * int64 count
        | _ -> failwith "Not possible.."

    let smallDistance = int64( abs ((fst destination) - (fst source)) + abs ((snd destination) - (snd source)))
    addCols (addRows smallDistance)             

let day11_2 image =
    let emptyRows = FindEmptyRows (List.indexed image) []
                    |> List.rev
    let emptyCols = FindEmptyRows (List.indexed (List.transpose image)) []
                              |> List.rev
    let LocalDistance = Distance emptyRows emptyCols 999999
    let hest =
     image 
     (* |> ExpandUnivers *)
     |> EnumerateGalaxies 
     |> GetGalaxyCoords
     |> List.map snd
     |> GetGalaxyPairs
     |> List.unzip      
    let fest = List.map2 LocalDistance (fst hest) (snd hest)
               |> List.sum
    fest / 2L

(day11_1) / 2 |> printfn "Day 11 part 1: %d"
day11_2 image |> printfn "day 11 part 2: %d"