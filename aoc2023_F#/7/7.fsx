let getValue card =
    match card with
    | 'A' -> 14
    | 'K' -> 13
    | 'Q' -> 12
    | 'J' -> 11
    | 'T' -> 10
    | '9' ->  9
    | '8' -> 8
    | '7' -> 7
    | '6' -> 6
    | '5' -> 5
    | '4' -> 4
    | '3' -> 3
    | '2' -> 2
    | _ -> failwith "invalid card"

// Completely stolen from Mads - Thanks buddy <3
let handleJoker x =
    match x with
    | 11 -> 1
    | x -> x

let convertJoker = function
    | 11 -> 1
    | x -> x

type Strength = FiveOfKind | FourOfKind | FullHouse | ThreeOfKind | TwoPair | OnePair | HighCard

let input = 
    System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc\\\\aoc2023_F#\\7\\input.txt")
    |> List.ofSeq
    |> List.map (fun (x:string) -> x.Split(" "))
    |> List.map (fun x -> (List.ofSeq x[0] , int64 x[1]))

let ofKind hand =
    let rec loop countedHand result =
     match countedHand with
     | [] -> result
     | (elem, count)::xs when count = 5 -> Some FiveOfKind
     | (elem, count)::xs when count = 4 -> Some FourOfKind
     | (elem, count)::xs when count = 3 -> Some ThreeOfKind
     | _::xs -> loop xs result
    loop (List.countBy id hand) None

let fullHouse hand =
    let countedHand = List.countBy id hand
    printfn "%A" countedHand
    if List.length (countedHand) = 2 && 
       (snd countedHand[0] = 2 && snd countedHand[1] = 3) ||
       (snd countedHand[0] = 3 && snd countedHand[1] = 2)
    then Some FullHouse
    else None

let ofPair hand = 
    let rec loop countedHand =
     match countedHand |> List.sortByDescending snd with
     | (v, 2) :: (v1, 2) :: rest -> TwoPair
     | (v, 2) :: rest -> OnePair
     | _ -> HighCard
    loop (List.countBy id hand)
    
let replaceJoker (hand:int list) : int list list =
    let cards = [2;3;4;5;6;7;8;9;10;11;12;13;14]
    let replace y x = if x = 1 then y else x
    let replacers = List.map replace cards
    let newHands = List.map (fun x -> List.map x hand) replacers
    newHands

let rec getScore hand =
    // Completely stolen from Mads - Thanks buddy <3
    let getHighJokerHandType =
        replaceJoker
        >> List.map getScore
        >> List.sort
        >> List.head 

    if List.contains 1 hand then
        getHighJokerHandType hand
    else
    match ofKind hand with
    | Some FiveOfKind -> FiveOfKind
    | Some FourOfKind -> match fullHouse hand with
                          | Some FullHouse -> printfn "jajaja"; FullHouse
                          | None -> FourOfKind
                          | _ -> failwith "impossibru"
    | Some ThreeOfKind -> match fullHouse hand with
                          | Some FullHouse ->  FullHouse
                          | None -> ThreeOfKind
                          | _ -> failwith "impossibru"
    | None -> match ofPair hand with
              | TwoPair -> TwoPair
              | OnePair -> OnePair
              | HighCard -> HighCard
              | _ -> failwith "impossibru"
    | _ -> failwith "impossibru"

let day7_1 input = 
    let rec loop result input =
        match input with
        | [] -> result
        | x::xs -> loop ((x, getScore (snd x)) :: result) xs
    loop [] input

let result = 
 List.map fst input 
 |> List.map (fun x -> List.map getValue x)
 |> List.zip (List.map snd input) 
 |> day7_1
 |> List.sortBy (fun ((a,b),c) -> b)
 |> List.sortByDescending (fun ((a,b),c) -> c)
 |> List.mapi (fun i ((a,b),c) -> (int64 (i+1)) * a)
 |> List.sum


let day7_2 = getValue >> handleJoker

let result2 = 
 List.map fst input 
 |> List.map (fun x -> List.map day7_2 x)
 |> List.zip (List.map snd input) 
 |> day7_1
 |> List.sortBy (fun ((a,b),c) -> b)
 |> List.sortByDescending (fun ((a,b),c) -> c)
 |> List.mapi (fun i ((a,b),c) -> (int64 (i+1)) * a)
 |> List.sum