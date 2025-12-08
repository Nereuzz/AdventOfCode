def solve1(input)
  numbers = 
  operators = input.last.split(' ')
  numbers = (input.take input.size - 1).map { 
    |line| line.split(' ')
  }.map {
      |inner| inner.map(&:to_i)
  }.transpose

  result = 0
  operators.each_with_index do |op, index|
    case op
    when "+"
      result += numbers[index].inject(0, :+)
    when "*"
      result += numbers[index].inject(1, :*)
    else
      throw "Unknown operator #{op}"
    end
  end
  result
end

def solve2(input)
  numbers = (input.take input.size - 1)
  operators = input.last
  totalProblems = operators.split(' ').size
  offset = 0
  result = 0
  
  (0..totalProblems - 1).each do |i|
    operator = operators[0]
    len = operators[1..].chars.take_while { |c| c == ' '}.size
    operators = operators[len + 1..]
    if i == totalProblems - 1
      len += 1
    end


    tmp = numbers.map { |line| line.chars[offset .. offset + len - 1]}
    tmp = tmp.transpose.map { |inner| (inner - [' ']).join()}.map(&:to_i)

    case operator
    when "+"
      result += tmp.inject(0, :+)
    when "*"
      result += tmp.inject(1, :*)
    end
    offset += len + 1
  end
  result
end



input = File.read("input.txt").split("\n")
puts "Part 1: #{solve1(input)}"
puts "Part 2: #{solve2(input)}"
