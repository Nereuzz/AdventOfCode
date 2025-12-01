def solve1(start, input)
  result = 0
  n = start
  input.each do |line|
    direction = line[0]
    steps = line[1..].to_i
    n = move(n, direction, steps)
    if (n == 0)
      result += 1
    end
  end
  result
end

def move(n, direction, steps)
  direction == 'L' ? (n - steps) % 100 : (n + steps) % 100
end

input = File.read("test.txt").split("\n")
puts "Part 1: #{solve1(50, input)}"
