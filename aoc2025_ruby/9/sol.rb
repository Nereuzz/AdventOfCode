def solve1(input)
  areas = []
  input.combination(2).each do |p1,p2|
    p1x, p1y = p1
    p2x, p2y = p2
    w = (p2x - p1x).abs + 1
    b = (p2y - p1y).abs + 1
    area = w * b
    areas.append([area,[p1,p2]])
  end
  areas
end


input = File.read("test.txt").split("\n").map { |p| p.split(',').map(&:to_i)}
puts "Part 1: #{solve1(input).sort.last[0]}"
