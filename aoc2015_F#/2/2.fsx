let input_1 = 
    System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc\\aoc2015_F#\\2\\input.txt") 
    |> List.ofSeq
    |> List.map (fun x -> (x.Split("x") |> List.ofSeq |> List.map int))


let getPaper (dimensions: int list) =
    let l = dimensions.[0]
    let w = dimensions.[1]
    let h = dimensions.[2]
    let lw = l * w
    let wh = w*h
    let hl = h*l
    2*lw + 2*wh + 2*hl + List.min [lw; wh; hl]

let day2_2 = List.map getPaper input_1 |> List.sum

let getRibbon dimensions =
    let rec loop d result =
     match d with
     | [] -> result
     | x :: xs -> printfn "%A" x
                  let tmp = List.filter (fun y -> y <> List.max x) x
                  let ribbon = List.reduce (fun a b -> a * b) x
                  match List.length tmp with
                  | 2 -> loop xs (result + tmp.[0]*2 + tmp.[1]*2 + ribbon)
                  | 1 -> loop xs (result + tmp.[0]*2 + (List.max x)*2 + ribbon)
                  | 0 -> loop xs (result + (List.max x)*4 + ribbon)
                  | _ -> failwith ""
                  
    loop dimensions 0

printfn "%A" <| getRibbon input_1

    

    

    