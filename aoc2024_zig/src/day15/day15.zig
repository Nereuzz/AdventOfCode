const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
const Point = struct { row: u64, col: u64 };
const Direction = enum { Up, Right, Down, Left };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = std.ArrayList([]u8).init(allocator);
    var map2 = std.ArrayList([]u8).init(allocator);
    defer {
        for (map.items) |row| allocator.free(row);
        for (map2.items) |row| allocator.free(row);
        map.clearAndFree();
        map2.clearAndFree();
    }

    var inputIter = std.mem.splitSequence(u8, input, "\n\n");
    const mapData = inputIter.next().?;

    var mapIter = std.mem.splitAny(u8, mapData, "\n");
    while (mapIter.next()) |line| {
        const row = try allocator.dupe(u8, line);
        const row2 = try allocator.dupe(u8, line);
        try map.append(row);
        try map2.append(row2);
    }

    var moves = std.mem.tokenizeScalar(u8, inputIter.next().?, '\n');

    const sol1 = try p1(map.items, moves.rest(), allocator);
    const sol2 = try p2(map2.items, moves.rest(), allocator);

    print("Day 15:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn p1(grid: [][]u8, moves: []const u8, allocator: std.mem.Allocator) !u64 {
    _ = allocator;

    var curPos: Point = GetStartPosition(grid);
    for (moves) |move| {
        if (move == '\n') continue;
        const nextPos: Point = GetPosition(move, curPos, 1);
        const next = grid[nextPos.row][nextPos.col];

        switch (next) {
            '.' => {
                grid[curPos.row][curPos.col] = '.';
                grid[nextPos.row][nextPos.col] = '@';
                curPos = nextPos;
            },
            '#' => continue,
            'O' => {
                if (gotSpace(grid, nextPos, move, 1)) |stones| {
                    var stoneIter: u64 = stones;
                    while (stoneIter > 0) {
                        const stonePos = GetPosition(move, curPos, stoneIter + 1);
                        grid[stonePos.row][stonePos.col] = 'O';
                        stoneIter -= 1;
                    }
                    grid[curPos.row][curPos.col] = '.';
                    grid[nextPos.row][nextPos.col] = '@';
                    curPos = nextPos;
                }
            },
            else => continue,
        }
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

fn p2(inGrid: [][]u8, moves: []const u8, allocator: std.mem.Allocator) !u64 {
    var bigGrid = std.ArrayList([]u8).init(allocator);
    defer bigGrid.deinit(); // Leak

    try expandGrid(inGrid, &bigGrid, allocator);
    const grid = bigGrid.items;

    var curPos: Point = GetStartPosition(grid);

    for (moves) |move| {
        if (move == '\n') continue;

        const nextPos: Point = GetPosition(move, curPos, 1);
        const next = grid[nextPos.row][nextPos.col];

        switch (next) {
            '#' => continue,
            '.' => {
                grid[curPos.row][curPos.col] = '.';
                grid[nextPos.row][nextPos.col] = '@';
                curPos = nextPos;
            },
            ']', '[' => {
                if (try MoveBox(grid, nextPos, next, move, true)) {
                    grid[curPos.row][curPos.col] = '.';
                    grid[nextPos.row][nextPos.col] = '@';
                    curPos = nextPos;
                } else continue;
            },
            else => {
                unreachable;
            },
        }
    }

    var result: u64 = 0;
    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == '[') {
                result += 100 * rowIdx + colIdx;
            }
        }
    }

    return result;
}

fn gotSpace(grid: [][]u8, pos: Point, direction: u8, spaces: u64) ?u64 {
    const nextPos = GetPosition(direction, pos, 1);
    const next = grid[nextPos.row][nextPos.col];

    switch (next) {
        '.' => return spaces,
        'O', '[', ']' => return gotSpace(grid, nextPos, direction, spaces + 1),
        '#' => return null,
        else => unreachable,
    }
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

fn mov(grid: [][]u8, oldLeft: Point, oldRight: Point, newLeft: Point, newRight: Point) void {
    grid[oldLeft.row][oldLeft.col] = '.';
    grid[oldRight.row][oldRight.col] = '.';
    grid[newLeft.row][newLeft.col] = '[';
    grid[newRight.row][newRight.col] = ']';
}

fn MoveBox(grid: [][]u8, boxPos: Point, boxPart: u8, direction: u8, withMov: bool) !bool {
    var posRight: Point = undefined;
    var posLeft: Point = undefined;

    if (boxPart == '[') {
        posLeft = boxPos;
        posRight = .{ .row = boxPos.row, .col = boxPos.col + 1 };
    } else {
        posRight = boxPos;
        posLeft = .{ .row = boxPos.row, .col = boxPos.col - 1 };
    }

    const newPosLeft = GetPosition(direction, posLeft, 1);
    const newPosRight = GetPosition(direction, posRight, 1);
    const nextLeft = grid[newPosLeft.row][newPosLeft.col];
    const nextRight = grid[newPosLeft.row][newPosRight.col];

    if (nextLeft == '#' or nextRight == '#') return false;

    if (nextLeft == ']' and nextRight == '[' and (direction == '^' or direction == 'v')) {
        if (try MoveBox(grid, newPosRight, nextRight, direction, false) and
            try MoveBox(grid, newPosLeft, nextLeft, direction, false))
        {
            _ = try MoveBox(grid, newPosRight, nextRight, direction, withMov);
            _ = try MoveBox(grid, newPosLeft, nextLeft, direction, withMov);
            if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
            return true;
        } else return false;
    }
    if (nextLeft == '[' and nextRight == ']' and (direction == '^' or direction == 'v')) {
        if (try MoveBox(grid, newPosLeft, nextLeft, direction, false)) {
            _ = try MoveBox(grid, newPosLeft, nextLeft, direction, withMov);
            if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
            return true;
        } else return false;
    }
    if (nextRight == '[' and (direction == '^' or direction == 'v')) {
        if (try MoveBox(grid, newPosRight, nextRight, direction, false)) {
            _ = try MoveBox(grid, newPosRight, nextRight, direction, withMov);
            if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
            return true;
        } else return false;
    }
    if (nextLeft == ']' and (direction == '^' or direction == 'v')) {
        if (try MoveBox(grid, newPosLeft, nextLeft, direction, false)) {
            _ = try MoveBox(grid, newPosLeft, nextLeft, direction, withMov);
            if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
            return true;
        } else return false;
    }
    if (nextLeft == '.' and direction == '<') {
        if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
        return true;
    }
    if (nextRight == '.' and direction == '>') {
        if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
        return true;
    }
    if (nextLeft == ']' and direction == '<') {
        if (try MoveBox(grid, newPosLeft, nextLeft, direction, false)) {
            _ = try MoveBox(grid, newPosLeft, nextLeft, direction, withMov);
            if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
            return true;
        } else return false;
    }
    if (nextRight == '[' and direction == '>') {
        if (try MoveBox(grid, newPosRight, nextRight, direction, false)) {
            _ = try MoveBox(grid, newPosRight, nextRight, direction, withMov);
            if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
            return true;
        } else return false;
    }

    if (nextLeft == '.' and nextRight == '.' and (direction == '^' or direction == 'v')) {
        if (withMov) mov(grid, posLeft, posRight, newPosLeft, newPosRight);
        return true;
    }

    unreachable;
}

fn expandGrid(grid: [][]u8, bigGrid: *std.ArrayList([]u8), allocator: std.mem.Allocator) !void {
    for (grid, 0..) |row, rowIdx| {
        var bigRow = std.ArrayList(u8).init(allocator);
        for (row, 0..) |col, colIdx| {
            _ = rowIdx;
            _ = colIdx;

            switch (col) {
                '#' => {
                    try bigRow.append(col);
                    try bigRow.append(col);
                },
                'O' => {
                    try bigRow.append('[');
                    try bigRow.append(']');
                },
                '.' => {
                    try bigRow.append('.');
                    try bigRow.append('.');
                },
                '@' => {
                    try bigRow.append('@');
                    try bigRow.append('.');
                },
                else => unreachable,
            }
        }
        try bigGrid.append(bigRow.items);
    }
}
