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
     File.ReadAllLines "20/input.txt"
     |> Seq.map (fun x -> x.Split("->") |> List.ofArray)
     |> List.ofSeq
     |> List.map (List.map (fun (y:string) -> y.Replace(" ", "")))
     |> List.map CreateModuleMap
     |> List.map (fun x -> (x.Name,x))
     |> Map.ofList
    let conses = Map.filter (fun k v -> match v.Type with |Conjunction _-> true |_ -> false) tmp |> Map.values |> Seq.cast<Module> |> List.ofSeq
    AddConjunctionsEntrypoints tmp conses

let rec AddSignalsToQueue queue source destinations pulse =
    match destinations with
    | [] -> queue
    | x::xs -> AddSignalsToQueue (queue @ [(source, x, pulse)]) source xs pulse

let PushButton queue =
    AddSignalsToQueue queue "button" ["broadcaster"] Low

let rec ResolveQueue (map:Map<string,Module>) result queue =
    match queue with
    | [] -> (map, result)
    | x::xs -> let (s,d,p) = x
               if d = "rx"
               then ResolveQueue map result xs
               else
               let m = Map.find d map
               match m.Type,p with
               | FlipFlop state, Low -> let map' = Map.add d {m with Type=FlipFlop (not state)} map
                                        let pulse = if state then Low else High
                                        let queue' = AddSignalsToQueue xs d m.Destination pulse
                                        let result' =
                                          if state
                                          then {result with Lows=result.Lows+(List.length m.Destination)}
                                          else {result with Highs=result.Highs+(List.length m.Destination)}
                                        ResolveQueue map' result' queue'
               | FlipFlop _, High -> ResolveQueue map result xs

               | Conjunction cmap, _ -> let cmap' = Map.add s p cmap
                                        let map' = Map.add d {m with Type=Conjunction cmap'} map
                                        let memory = cmap'.Values |> Seq.cast<Pulse> |> List.ofSeq
                                        let result',queue' = 
                                         if  List.forall (fun x -> match x with High -> true | Low -> false) memory
                                         then {result with Lows = result.Lows+List.length m.Destination},AddSignalsToQueue xs d m.Destination Low
                                         else {result with Highs = result.Highs+List.length m.Destination},AddSignalsToQueue xs d m.Destination High
                                        ResolveQueue map' result' queue'
               | Broadcaster, _ -> let queue' = AddSignalsToQueue xs d m.Destination Low
                                   let result' = {result with Lows=result.Lows+List.length m.Destination}
                                   ResolveQueue map result' queue'                      
                                     
let rec PushButtonNTimes map result times =
    
    match times with
    | 0 -> result
    | _ -> let (map', result') = ResolveQueue map result (PushButton [])
           let result'' = {result' with Lows=result'.Lows+1}
           PushButtonNTimes map' result'' (times - 1)
    

let hmm = PushButtonNTimes input {Highs=0; Lows=0} 1000
printfn "day 20 part 1: %d" (hmm.Highs * hmm.Lows)