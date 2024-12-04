const std = @import("std");
const input = @embedFile("input.txt");
const print = std.debug.print;

pub fn main() !void {
    const wordPlay = loadWordplayFromFile();
    print("Day 4:\n", .{});
    const sol1 = p1(wordPlay);
    print("Part 1: {}\n", .{sol1});
    const sol2 = p2(wordPlay);
    print("Part 2: {}\n", .{sol2});
}

fn p1(wordPlay: [140][140]u8) u64 {
    var result: u64 = 0;
    for (wordPlay, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == 'X') {
                if (checkUp(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
                if (checkUpRight(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
                if (checkRight(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
                if (checkDownRight(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
                if (checkDown(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
                if (checkLeftDown(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
                if (checkLeft(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
                if (checkUpLeft(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
            }
        }
    }
    return result;
}

fn p2(wordPlay: [140][140]u8) u64 {
    var result: u64 = 0;
    for (wordPlay, 0..) |row, rowIdx| {
        if (rowIdx < 1 or rowIdx > 138) {
            continue;
        }
        for (row, 0..) |col, colIdx| {
            if (colIdx < 1 or colIdx > 138) {
                continue;
            }
            if (col == 'A') {
                if (checkTwoMas(wordPlay[0..][0..], rowIdx, colIdx)) {
                    result += 1;
                }
            }
        }
    }
    return result;
}

fn checkTwoMas(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    return ((wordPlay[rowIdx - 1][colIdx - 1] == 'M' and wordPlay[rowIdx + 1][colIdx + 1] == 'S') or
        (wordPlay[rowIdx - 1][colIdx - 1] == 'S' and wordPlay[rowIdx + 1][colIdx + 1] == 'M')) and
        ((wordPlay[rowIdx - 1][colIdx + 1] == 'M' and wordPlay[rowIdx + 1][colIdx - 1] == 'S') or
        (wordPlay[rowIdx - 1][colIdx + 1] == 'S' and wordPlay[rowIdx + 1][colIdx - 1] == 'M'));
}

fn checkUp(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (rowIdx < 3)
        return false;
    return wordPlay[rowIdx - 1][colIdx] == 'M' and
        wordPlay[rowIdx - 2][colIdx] == 'A' and
        wordPlay[rowIdx - 3][colIdx] == 'S';
}

fn checkUpRight(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (rowIdx < 3 or colIdx > 136) {
        return false;
    }
    return wordPlay[rowIdx - 1][colIdx + 1] == 'M' and
        wordPlay[rowIdx - 2][colIdx + 2] == 'A' and
        wordPlay[rowIdx - 3][colIdx + 3] == 'S';
}

fn checkRight(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (colIdx > 136) {
        return false;
    }
    return wordPlay[rowIdx][colIdx + 1] == 'M' and
        wordPlay[rowIdx][colIdx + 2] == 'A' and
        wordPlay[rowIdx][colIdx + 3] == 'S';
}

fn checkDownRight(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (rowIdx > 136 or colIdx > 136) {
        return false;
    }
    return wordPlay[rowIdx + 1][colIdx + 1] == 'M' and
        wordPlay[rowIdx + 2][colIdx + 2] == 'A' and
        wordPlay[rowIdx + 3][colIdx + 3] == 'S';
}

fn checkDown(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (rowIdx > 136) {
        return false;
    }
    return wordPlay[rowIdx + 1][colIdx] == 'M' and
        wordPlay[rowIdx + 2][colIdx] == 'A' and
        wordPlay[rowIdx + 3][colIdx] == 'S';
}

fn checkLeftDown(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (rowIdx > 136 or colIdx < 3) {
        return false;
    }
    return wordPlay[rowIdx + 1][colIdx - 1] == 'M' and
        wordPlay[rowIdx + 2][colIdx - 2] == 'A' and
        wordPlay[rowIdx + 3][colIdx - 3] == 'S';
}
fn checkLeft(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (colIdx < 3) {
        return false;
    }
    return wordPlay[rowIdx][colIdx - 1] == 'M' and
        wordPlay[rowIdx][colIdx - 2] == 'A' and
        wordPlay[rowIdx][colIdx - 3] == 'S';
}

fn checkUpLeft(wordPlay: *const [140][140]u8, rowIdx: u64, colIdx: u64) bool {
    if (rowIdx < 3 or colIdx < 3) {
        return false;
    }
    return wordPlay[rowIdx - 1][colIdx - 1] == 'M' and
        wordPlay[rowIdx - 2][colIdx - 2] == 'A' and
        wordPlay[rowIdx - 3][colIdx - 3] == 'S';
}

fn loadWordplayFromFile() [140][140]u8 {
    var iter = std.mem.tokenizeAny(u8, input, "\n");
    var wordPlay: [140][140]u8 = undefined;
    var rowIdx: u64 = 0;
    while (iter.next()) |row| {
        var colIdx: u64 = 0;
        for (row) |letter| {
            wordPlay[rowIdx][colIdx] = letter;
            colIdx += 1;
        }
        rowIdx += 1;
    }
    return wordPlay;
}
