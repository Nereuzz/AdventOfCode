let day1_1 = 
    System.IO.File.ReadAllText("C:\\Users\\Thoms\\code\\aoc\\aoc2015_F#\\1\\input.txt")
    |> List.ofSeq
    |> List.fold (fun acc x -> match x with
                                            | '(' -> acc + 1
                                            | ')' -> acc - 1
                                            | _ -> failwith "") 0
                                            

let data = System.IO.File.ReadAllText("C:\\Users\\Thoms\\code\\aoc\\aoc2015_F#\\1\\input.txt") |> List.ofSeq 

let rec day1_2 ahh idx acc =
    match ahh with
    | x::xs -> match acc with
               | -1 -> idx
               | _ -> match x with
                      | '(' -> day1_2 xs (idx+1) (acc+1)
                      | ')' -> day1_2 xs (idx+1) (acc-1)
                      | _ -> failwith ""
    | _ -> failwith ""

day1_2 data 0 0