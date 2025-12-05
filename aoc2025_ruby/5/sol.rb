def solve1(input)
  result = []
  ranges = input[0].split("\n")
  ingredients = input[1].split("\n")

  ranges.each do |range|
    tmp = range.split("-")
    low = tmp[0].to_i
    high = tmp[1].to_i

    ingredients.map { |i| i.to_i }.sort().each do |i|
      if (i >= low and i <= high)
        ingredients.delete(i.to_s)
        result.append(i)
      end
    end

  end
  result.length
end

def solve2(input)
  ranges = (input.split("\n").map {|c| c.split("-")}).map {|t| [t[0].to_i, t[1].to_i]}.sort()
  resultingRanges = []

  while (ranges.length > 0)
    oldRanges = resultingRanges
    low = ranges[0][0]
    high = ranges[0][1]
    haha = findRange(ranges, [low,high])
    ranges = haha[0]
    resultingRanges.append(haha[1])
  end

  resultingRanges.map {|r| r[1] - r[0] + 1}.sum()
end

def findRange(ranges, result)
  if ranges[1].nil?
    result[1] = [result[1], ranges[0][1]].max if overlaps(result, ranges[0])
    return [], result
  end

  if result[0] <= ranges[1][1] and result[1] >= ranges[1][0]
    result[1] = [result[1], ranges[1][1]].max
    return findRange(ranges[1..], result)
  end

  return ranges[1..], result
end

input = File.read("input.txt").split("\n\n")
puts "Part 1: #{solve1(input)}"
puts "Part 2: #{solve2(input[0])}"
