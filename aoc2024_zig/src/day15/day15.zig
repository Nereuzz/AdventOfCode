const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

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

    const sol1 = try p1(map.items, moves.next().?, allocator);

    print("Day 15:\nPart 1: {}\n", .{sol1});
}

fn p1(grid: [][]u8, moves: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = allocator;

    var cur_pos: Point = GetStartPosition(grid);
    for (moves) |move| {
        for (grid) |row| {
            print("{s}\n", .{row});
        }

        const targetPos: Point = GetNextPosition(move, cur_pos);
        const next = grid[targetPos.row][targetPos.col];
        print("{c} -- {c}\n", .{ move, next });
        if (next == '.') {
            grid[cur_pos.row][cur_pos.col] = '.';
            grid[targetPos.row][targetPos.col] = '@';
            cur_pos = targetPos;
        }
        if (next == '#') {
            continue;
        }
        if (next == 'O') {
            if (gotSpace(grid, targetPos, move, 1)) |spaces| {} else continue;
        }
    }

    print("\n", .{});

    return 0;
}

fn gotSpace(grid: [][]u8, pos: Point, direction: u8, spaces: u64) ?u64 {
    const nextPos = GetNextPosition(direction, pos);
    const next = grid[nextPos.row][nextPos.col];
    if (next == '.') return spaces;
    if (next == 'O') return gotSpace(grid, nextPos, direction, spaces + 1);
    if (next == '#') return null;
    unreachable;
}

fn GetNextPosition(direction: u8, cur_pos: Point) Point {
    return switch (direction) {
        '^' => .{ .row = cur_pos.row - 1, .col = cur_pos.col },
        '>' => .{ .row = cur_pos.row, .col = cur_pos.col + 1 },
        'v' => .{ .row = cur_pos.row + 1, .col = cur_pos.col },
        '<' => .{ .row = cur_pos.row, .col = cur_pos.col - 1 },
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
