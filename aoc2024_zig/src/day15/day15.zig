const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.ArrayList([]u8).init(allocator);
    defer {
        for (map.items) |row| allocator.free(row);
        map.clearAndFree();
    }

    var inputIter = std.mem.splitSequence(u8, input, "\n\n");
    const mapData = inputIter.next().?;

    var mapIter = std.mem.splitAny(u8, mapData, "\n");
    while (mapIter.next()) |line| {
        // print("{s}\n", .{line});
        const row = try allocator.dupe(u8, line);
        try map.append(row);
    }

    var moves = std.mem.tokenizeScalar(u8, inputIter.next().?, '\n');

    const sol1 = try p1(map.items, moves.rest(), allocator);

    print("Day 15:\nPart 1: {}\n", .{sol1});
}

fn p1(grid: [][]u8, moves: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = allocator;

    var curPos: Point = GetStartPosition(grid);
    for (moves) |move| {
        if (move == '\n') continue;
        const nextPos: Point = GetPosition(move, curPos, 1);
        const next = grid[nextPos.row][nextPos.col];
        // print("{c} -- {c}\n", .{ move, next });
        if (next == '.') {
            grid[curPos.row][curPos.col] = '.';
            grid[nextPos.row][nextPos.col] = '@';
            curPos = nextPos;
        }
        if (next == '#') {
            continue;
        }
        if (next == 'O') {
            if (gotSpace(grid, nextPos, move, 1)) |stones| {
                var stoneIter: u64 = stones;
                // print("stoneIter: {}\n", .{stoneIter});
                while (stoneIter > 0) {
                    const stonePos = GetPosition(move, curPos, stoneIter + 1);
                    // print("{any}\n", .{stonePos});
                    grid[stonePos.row][stonePos.col] = 'O';
                    stoneIter -= 1;
                }
                grid[curPos.row][curPos.col] = '.';
                grid[nextPos.row][nextPos.col] = '@';
                curPos = nextPos;
            }
        } else continue;
    }

    var result: u64 = 0;

    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == 'O') {
                result += 100 * rowIdx + colIdx;
            }
        }
    }

    return result;
}

fn gotSpace(grid: [][]u8, pos: Point, direction: u8, spaces: u64) ?u64 {
    const nextPos = GetPosition(direction, pos, 1);
    const next = grid[nextPos.row][nextPos.col];
    if (next == '.') return spaces;
    if (next == 'O') return gotSpace(grid, nextPos, direction, spaces + 1);
    if (next == '#') return null;
    unreachable;
}

fn GetPosition(direction: u8, curPos: Point, n: usize) Point {
    return switch (direction) {
        '^' => .{ .row = curPos.row - n, .col = curPos.col },
        '>' => .{ .row = curPos.row, .col = curPos.col + n },
        'v' => .{ .row = curPos.row + n, .col = curPos.col },
        '<' => .{ .row = curPos.row, .col = curPos.col - n },
        else => undefined,
    };
}

fn GetStartPosition(grid: [][]u8) Point {
    for (grid, 0..) |row, rowIdx| {
        if (std.mem.indexOf(u8, row, "@")) |col| {
            return .{ .row = rowIdx, .col = col };
        }
    }
    unreachable;
}

const Point = struct { row: u64, col: u64 };
const Direction = enum { Up, Right, Down, Left };
