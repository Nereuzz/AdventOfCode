
def solve1(input)
  result = []
  ranges = input[0].split("\n")
  ingredients = input[1].split("\n")

  ranges.each do |range|
    tmp = range.split("-")
    low = tmp[0].to_i
    high = tmp[1].to_i

    ingredients.sort().each do |i|
      i = i.to_i
      if (i >= low and i <= high)
        ingredients.delete(i.to_s)
        result.append(i)
      end
    end

  end
  result.length
end

input = File.read("input.txt").split("\n\n")
puts "Part 1: #{solve1(input)}"


# 510 too low - off by one without sorting?
