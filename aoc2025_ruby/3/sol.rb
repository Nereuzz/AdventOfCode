def solve(banks,len)
  result = 0
  banks.each do |bank|
    result += findSmart(bank.chars.map { |c| c.to_i}, len, "")
  end
  result
end

def findSmart(batteries, len, result)
  return result.to_i if result.length == len

  max = batteries.max()
  maxIdx = batteries.index(max)

  while (maxIdx > batteries.length - len + result.length)
    maxIdx = batteries.index(max - 1)
    maxIdx = 99 if maxIdx.nil?
    max -= 1
  end

  if result.length == len
    result[-1] = max if result[-1].to_i < max
  else
    result += max.to_s
  end

  findSmart(batteries[maxIdx + 1..], len, result)
end

input = File.read("input.txt").split("\n")
puts "Part 1: #{solve2(input, 2)}"
puts "Part 2: #{solve2(input, 12)}"



