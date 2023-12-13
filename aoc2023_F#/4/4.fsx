type Card = {
    id:int;
    winningNumbers:int list;
    drawnNumbers: int list;
    score: int;
    mutable copies: int;
}

let parseCard (input:string) =
    let id = int (input.Split(":")[0]).[5..]
    let winningNumbers = let fst = input.Split(":")[1] in
                                    let snd =  (string(fst).Split("|"))[0] in
                                    List.map (fun x -> int x) (List.ofSeq <| Seq.filter (fun x -> x <> "") (snd.Split(" ")))

    let drawnNumbers = let fst = input.Split(":")[1] in
                                    let snd =  (string(fst).Split("|"))[1] in
                                    List.map (fun x -> int x) (List.ofSeq <| Seq.filter (fun x -> x <> "") (snd.Split(" ")))
 
    {id=id; winningNumbers=winningNumbers; drawnNumbers=drawnNumbers; score=0; copies=0}

let getScores (card:Card) =
    let scoringNumbers = List.ofSeq <| Set.intersect (Set.ofList card.winningNumbers) (Set.ofList card.drawnNumbers)
    printfn "%A" scoringNumbers
    if List.length scoringNumbers > 0 
    then {id=card.id; winningNumbers=card.winningNumbers; drawnNumbers=card.drawnNumbers; 
          score=List.fold (fun acc number -> acc * number) 1 (List.replicate (List.length scoringNumbers-1) 2); copies = 0 }
    else {id=card.id; winningNumbers=card.winningNumbers; drawnNumbers=card.drawnNumbers; score=0; copies=0}

let input = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\4\\input.txt") |> List.ofSeq
let day4_1  = List.fold (fun acc x -> x.score + acc) 0 (List.map getScores (List.map parseCard input))

let rec PlayGame (cards:Card list) =
    let rec AddCopies cards idsWon =
        let rec FindAndAddCard cards id =
            match cards with
            | c::_ when c.id = id -> c.copies <- c.copies+1 
            | _::cs -> FindAndAddCard cs id
            | [] -> failwith "Impossible!"
        for id in idsWon do
            FindAndAddCard cards id

    match cards with
    | c::cs -> let copiesWon = List.length (List.ofSeq <| Set.intersect (Set.ofList c.winningNumbers) (Set.ofList c.drawnNumbers))
               let idsWon = [c.id+1..(c.id+copiesWon)]
               for _ in [0..c.copies] do
                  AddCopies cards idsWon
               c :: PlayGame cs
    | _ -> []
let input1 = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\4\\input.txt") |> List.ofSeq

let day4_2 = List.sum <| List.map (fun x -> x.copies + 1) (PlayGame (List.map parseCard input1))