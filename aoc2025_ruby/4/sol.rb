def solve(input, part)
  grid = []
  input.each do |row|
    grid.append(row.chars.prepend('.').append('.'))
  end

  rows = grid.length
  cols = grid[0].length
  grid = grid.prepend(Array.new(cols, '.')).append(Array.new(cols, '.'))

  return removeRolls(grid, rows, cols, part)[1] if part == 1

  result = 0
  iterResult = removeRolls(grid, rows, cols, part)
  result += iterResult[1]
  while iterResult[1] != 0
    iterResult = removeRolls(iterResult[0], rows, cols, part)
    result += iterResult[1]
  end
  result
end

def removeRolls(grid, rows, cols, part) 
  result = 0
  coordsToFix = []
  for row in (1..rows)
    for col in (1..cols-1)
      next if grid[row][col] == '.'

      paperRolls = -1
      grid[row-1..row+1].each do |windowRows|
        paperRolls += windowRows[col-1..col+1].count('@')
      end

      if paperRolls < 4
        result += 1
        coordsToFix.append([row, col]) if part == 2
      end

    end
  end

  coordsToFix.each do |coord| 
    grid[coord[0]][coord[1]] = '.'
  end if part == 2

  return grid, result
end


input = File.read("input.txt").split("\n")
puts "Part 1: #{solve(input, 1)}"
puts "Part 2: #{solve(input, 2)}"
