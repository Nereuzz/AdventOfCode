type Almanace = {
    seeds :int64 list;
    seedToSoil :int64 list list;
    soilToFertilizer: int64 list list;
    fertilizerToWater: int64 list list;
    waterToLight: int64 list list;
    lightToTemp: int64 list list;
    tempToHumid: int64 list list;
    humidToLocation: int64 list list;
}

let input1 = System.IO.File.ReadLines("C:\\Users\\Thoms\\code\\aoc2023\\5\\input.txt") |> List.ofSeq

let parseInput (input:string list) =
    let rec getEntries list =
        match list with
        | x::xs when x <> "" -> x :: getEntries xs
        | _ -> []
    let rec loop list = 
        match list with
        | [] -> []
        | x::xs when x = "" -> loop xs
        | x::xs -> let entries = getEntries xs
                   entries :: loop xs[List.length entries..]
    let seeds = input.[0]
    let workList = input.[2..]
    [seeds[7..]] :: (loop workList)

let getAlmanaceFromMap (map: int64 list list list) = {
    seeds=map.[0][0];
    seedToSoil=map.[1];
    soilToFertilizer=map.[2]
    fertilizerToWater=map.[3];
    waterToLight=map.[4];
    lightToTemp=map.[5];
    tempToHumid=map.[6];
    humidToLocation=map.[7]
      }

let Alma = getAlmanaceFromMap (List.map (fun x -> List.map (fun (x:string) -> List.map (fun x -> int64 x) (List.ofSeq <| x.Split(" "))) x ) (parseInput input1))

let resolveMap (map: int64 list list) seed =
    let rec loop (map: int64 list list) = 
        match map with
        | [] -> seed
        | x::xs -> let destinationRange = x.[0]
                   let sourceRange = x.[1]
                   let rangeLength = x.[2]
                   match sourceRange <= seed && seed < (sourceRange + rangeLength) with
                   | true -> seed - sourceRange + destinationRange
                   | false -> loop xs
    let result = loop map
    (* printfn "Result for seed %A == %A" seed result *)
    result

let getLocation seed =
    (* printfn "Seed getting checked: %A" seed *)
    seed 
    |> resolveMap Alma.seedToSoil 
    |> resolveMap Alma.soilToFertilizer 
    |> resolveMap Alma.fertilizerToWater
    |> resolveMap Alma.waterToLight
    |> resolveMap Alma.lightToTemp
    |> resolveMap Alma.tempToHumid
    |> resolveMap Alma.humidToLocation
   
(* let day5_1 = List.map getLocation Alma.seeds |> List.sort |> List.head *)

let GetLocationForSeedRange seeds =
    let rec pairs seedList =
     match seedList with
     | [] -> []
     | x::xs::xss -> (x, xs) :: pairs xss
     | _ -> failwith "Not possible..."

    let rec resolveSeedPair seedInit seedRange result =
     match seedRange with
     | 0L -> result //printfn "I am result in resolvePair: %A" result; result
     | _ -> let location = getLocation seedInit
            match location < result with
            | true -> resolveSeedPair (seedInit+1L) (seedRange-1L) location
            | false -> resolveSeedPair (seedInit+1L) (seedRange-1L) result

    let rec getLocationForPair seedList result =
     (* printfn "seedList %A" seedList *)
     match seedList with
     | [] -> result
     | x::xs -> let (seedInit, seedRange) = x
                match seedRange with
                | 0L -> getLocationForPair xs result
                | _ -> getLocationForPair xs (resolveSeedPair seedInit seedRange result)

    getLocationForPair (pairs seeds) 999999999999999999L
     

GetLocationForSeedRange Alma.seeds
