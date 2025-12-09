def solve1(input)
  distances = Hash.new(0)
  circuits = Hash.new([])
  circuitLengths = Hash.new(0)

  input.each_with_index do |p1, idx|
    input[idx+1..].each_with_index do |p2, idx2|
      key = p1[0],p2[0]
      distance = Math.sqrt((p1[1][0] - p2[1][0])**2+(p1[1][1] - p2[1][1])**2+(p1[1][2]-p2[1][2])**2)
      distances[key] = distance
    end
  end

  nextCircuit = 0
  counter = 0
  part1 = 0
  part2 = 0
  prevFirst = 0
  prevSecond = 0
  distances.sort_by(&:last).each do |d|
    first = d[0][0]
    second = d[0][1]
    firstExists = circuits.key?(first)
    secondExists = circuits.key?(second)
    counter += 1
    if circuitLengths.key(input.length)
      part2 = input[prevFirst][1][0] * input[prevSecond][1][0]
      break
    end
    if counter == 1001
      part1 = circuitLengths.values.sort.reverse.take(3).inject(1, &:*)
    end

    if firstExists and secondExists
      next if circuits[first] == circuits[second]

      circuitSource = circuits[second]
      circuitDestination = circuits[first]
      keysToMove = circuits.select { |k,v| v == circuitSource }.keys
      keysToMove.each do |k|
        circuits[k] = circuitDestination
      end
      circuitLengths[circuitDestination] += keysToMove.length
      circuitLengths[circuitSource] = 0
    elsif firstExists
      circuits[second] = circuits[first]
      circuitLengths[circuits[first]] += 1
    elsif secondExists
      circuits[first] = circuits[second]
      circuitLengths[circuits[second]] += 1
    else

    circuits[first] = nextCircuit
    circuits[second] = nextCircuit
    circuitLengths[nextCircuit] += 2
    nextCircuit += 1
    end
    prevFirst = first
    prevSecond = second
  end


  return part1, part2

end


input = File.read("input.txt").split("\n")
  .map { |l| l.split(',') }
  .map {|t| t.map(&:to_i)}
  .map.with_index {|p, i| [i, p]}
answer = solve1(input)
puts "Part 1: #{answer[0]}"
puts "Part 2: #{answer[1]}"
