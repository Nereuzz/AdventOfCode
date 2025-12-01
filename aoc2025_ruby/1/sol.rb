def solve1(start, input)
  result = 0
  n = start
  input.each do |line|
    direction = line[0]
    steps = line[1..].to_i
    n = move(n, direction, steps) % 100
    if (n == 0)
      result += 1
    end
  end
  result
end

def solve2(start, input)
  result = 0
  n = start
  input.each do |line|
    direction = line[0]
    steps = line[1..].to_i

    dialUnmapped = move(n, direction, steps)
    wraps = (dialUnmapped / 100).abs
    newN = dialUnmapped % 100

    if direction == 'L'
      wraps -= 1 if n == 0
      result += 1 if newN == 0
    end

    result += wraps
    n = newN
  end
  result
end

def move(n, direction, steps)
  direction == 'L' ? (n - steps) : (n + steps)
end

input = File.read("test.txt").split("\n")
puts "Part 1: #{solve1(50, input)}"
puts "Part 2: #{solve2(50, input)}"

#puts "debug: #{solve2(50, ["L50"]) == 1}"
#puts "debug: #{solve2(50, ["L150"]) == 2}"
#puts "debug: #{solve2(50, ["L151"]) == 2}"
#puts "debug: #{solve2(0, ["L1"]) == 0}"
#puts "debug: #{solve2(0, ["L100"]) == 1}"
#puts "debug: #{solve2(0, ["L101"]) == 1}"
#puts "debug: #{solve2(0, ["R1"]) == 0}"
#puts "debug: #{solve2(0, ["R100"]) == 1}"
#puts "debug: #{solve2(0, ["R101"]) == 1}"
#puts "debug: #{solve2(50, ["R50"]) == 1}"
#puts "debug: #{solve2(50, ["R150"]) == 2}"
#puts "debug: #{solve2(50, ["R151"]) == 2}"
