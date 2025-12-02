

def solve1(ranges)
  result = []
  ranges.each do |range|
    dashIdx = range.index('-')
    lower = range[0..dashIdx-1].to_i
    higher = range[dashIdx+1..].to_i

    (lower..higher).each do |num|
      result.append(num) if isMirrorNumber?(num.to_s)
    end
  end
  result.sum()
end


def isMirrorNumber?(str)
  if str.length % 2 != 0
    return false
  end

  mid = str.length / 2
  first = str[0..mid-1].to_i
  last = str[mid..].to_i

  return first == last
end

ranges = File.read("input.txt").split(',')
puts "Part 1: #{solve1(ranges)}"
