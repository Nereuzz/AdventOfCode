def solve(input)
  beamPos = []
  input.each_with_index do |row, idx|
    beamPos << [idx, row.index("S")] if row.index('S')
  end

  splits = 0
  paths = Hash.new(0)
  paths[beamPos[0]] = 1

  (0..input.length - 2).each do |hehe|
    beamPos = moveBeams(beamPos)
    nextPos = []
    beamPos.each do |pos|
      case input[pos[0]][pos[1]]
      when '.'
        nextPos.append(pos)
        paths[pos] += paths[prevPos(pos)]
        paths.delete(prevPos(pos))
        next
      when '^'
        newPositions = [pos[0], pos[1]-1],[pos[0],pos[1]+1]

        paths[newPositions[0]] += paths[prevPos(pos)].to_i
        paths[newPositions[1]] += paths[prevPos(pos)].to_i
        paths.delete(prevPos(pos))

        nextPos.append(newPositions[0])
        nextPos.append(newPositions[1])
        splits += 1
        next
      end
    end
    beamPos = nextPos.uniq
  end

  [splits, paths.values.sum]
end

def prevPos(pos)
  [pos[0]-1, pos[1]]
end

def moveBeams(beamPos)
  beamPos.map do |pos|
    [pos[0]+1, pos[1]]
  end
end


input = File.read("input.txt").split("\n").map(&:chars)
answer = solve(input)
puts "Part 1: #{answer[0]}"
puts "PART 2: #{answer[1]}"
