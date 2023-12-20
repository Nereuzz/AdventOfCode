open System.IO

type Pulse =
    | Low
    | High

type ModuleType =
    | FlipFlop of bool
    | Conjunction of Map<string,Pulse>
    | Broadcaster

type Module = {
    Type:ModuleType
    Name:string;
    Destination:string list
}

type Result = {
    Lows:int
    Highs:int
}

let rec AddDestinationsToConjunction map entries conjunction =
    printfn $"Adding Cons for %A{conjunction} and modules that enters: %A{entries}"
    match entries with
    | [] -> map
    | x::xs -> let (Conjunction conjMap) = conjunction.Type
               let newConjunction = {conjunction with Type=Conjunction (Map.add x.Name Low conjMap)}
               AddDestinationsToConjunction (Map.add conjunction.Name newConjunction map) xs newConjunction

let rec AddConjunctionsEntrypoints map conjunctions =
    match conjunctions with
    | [] -> map
    | x::xs -> let mapValues = Map.filter (fun _ v -> List.contains x.Name v.Destination) map |> Map.values |> Seq.cast<Module> |> List.ofSeq
               AddConjunctionsEntrypoints (AddDestinationsToConjunction map mapValues x) xs


let CreateModuleMap wireModule =
    match wireModule with
    | [name; destination] when name = "broadcaster" -> {Type=Broadcaster; Name = name; Destination = destination.Split(",") |> List.ofSeq }
    | [name; destination] when name.StartsWith("%") -> {Type=FlipFlop false; Name=name.Substring 1; Destination = destination.Split(",") |> List.ofSeq }
    | [name; destination] when name.StartsWith("&") -> {Type=Conjunction Map.empty; Name=name.Substring 1; Destination = destination.Split(",") |> List.ofSeq }

let input =
    let tmp =
     File.ReadAllLines "20/test.txt"
     |> Seq.map (fun x -> x.Split("->") |> List.ofArray)
     |> List.ofSeq
     |> List.map (List.map (fun (y:string) -> y.Replace(" ", "")))
     |> List.map CreateModuleMap
     |> List.map (fun x -> (x.Name,x))
     |> Map.ofList
    let conses = Map.filter (fun k v -> match v.Type with |Conjunction _-> true |_ -> false) tmp |> Map.values |> Seq.cast<Module> |> List.ofSeq
    AddConjunctionsEntrypoints tmp conses

let queue = [("button","broadcaster",Low)]

let rec AddSignalsToQueue queue source destinations pulse =
    match destinations with
    | [] -> queue
    | x::xs -> AddSignalsToQueue (queue @ [(source, x, pulse)]) source xs pulse

let rec ResolveQueue (map:Map<string,Module>) result queue =
    match queue with
    | [] -> result
    | x::xs -> let (s,d,p) = x
               let m = Map.find d map
               match m.Type,p with
               | FlipFlop state, Low -> let map' = Map.add d {m with Type=FlipFlop (not state)} map
                                        let pulse = if state then Low else High
                                        let queue' = AddSignalsToQueue queue d m.Destination pulse
                                        let result' =
                                            if state
                                            then {result with Lows=result.Lows+(List.length m.Destination)}
                                            else {result with Highs=result.Highs+(List.length m.Destination)}
                                        ResolveQueue map' result' queue'
               | FlipFlop state, High -> ResolveQueue map result queue
               | Conjunction cmap -> let cmap' = Map.Add s p cmap
                                     let map' = Map.add d {m with Type=Conjunction cmap'} map
                                     
