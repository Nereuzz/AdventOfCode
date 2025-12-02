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

def solve2(ranges)
  result = []
  ranges.each do |range|
    dashIdx = range.index('-')
    lower = range[0..dashIdx -1].to_i
    higher = range[dashIdx + 1..].to_i

    (lower..higher).each do |num|
      result.append(num) if isRepetetiveSubSequence?(num.to_s)
    end
  end
  result.sum()
end

def isRepetetiveSubSequence?(str)
  return str[0] == str[1] if str.length == 2
  return str.chars.uniq.size == 1 if str.length == 3

  mid = str.length / 2
  idx = 0
  while (idx <= mid)
    seq = str[0..idx]
    return false if seq.length > mid

    while (seq == str[idx + 1..idx + seq.length])
      idx += seq.length
      return true if idx >= str.length - 1
    end
    idx += 1
  end

  return false
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
puts "Part 2: #{solve2(ranges)}"
