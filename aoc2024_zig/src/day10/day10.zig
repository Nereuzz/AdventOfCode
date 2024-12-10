const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
const rows = 52;
const cols = 52;

const Point = struct { x: u64, y: u64 };

pub fn main() !void {
    const sol1 = try p1();
    const sol2 = try p2();

    print("Day 11:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn p1() !u64 {
    var result: u64 = 0;
    const map = try read_input();
    var heads: [1000]Point = undefined;
    var headsIdx: u64 = 0;
    for (map, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == '0') {
                heads[headsIdx] = .{ .x = rowIdx, .y = colIdx };
                headsIdx += 1;
            }
        }
    }
    for (heads) |head| {
        if (head.x > cols) {
            break;
        }
        result += try bfs(map, head, false);
    }
    return result;
}

fn p2() !u64 {
    var result: u64 = 0;
    const map = try read_input();
    var heads: [1000]Point = undefined;
    var headsIdx: u64 = 0;
    for (map, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == '0') {
                heads[headsIdx] = .{ .x = rowIdx, .y = colIdx };
                headsIdx += 1;
            }
        }
    }
    for (heads) |head| {
        if (head.x > cols) {
            break;
        }
        result += try bfs(map, head, true);
    }
    return result;
}

fn bfs(map: [rows][cols]u8, start: Point, part2: bool) !u64 {
    const allocator = std.heap.page_allocator;
    var queue = std.fifo.LinearFifo(Point, .Dynamic).init(allocator);
    try queue.writeItem(start);

    var nines = try std.BoundedArray(Point, 10000).init(0);
    while (queue.readItem()) |v| {
        if (map[v.x][v.y] == '9') {
            if (part2) {
                try nines.append(v);
            } else {
                var inNines = false;
                for (nines.slice()) |nine| {
                    if (std.meta.eql(nine, v)) {
                        inNines = true;
                        break;
                    }
                }
                if (!inNines) {
                    try nines.append(v);
                }

                if (nines.slice().len == 0) {
                    try nines.append(v);
                }
            }
        }

        if (v.x != 0 and map[v.x - 1][v.y] == map[v.x][v.y] + 1) {
            try queue.writeItem(.{ .x = v.x - 1, .y = v.y });
        }
        if (v.x + 1 < map[0].len and map[v.x + 1][v.y] == map[v.x][v.y] + 1) {
            try queue.writeItem(.{ .x = v.x + 1, .y = v.y });
        }
        if (v.y != 0 and map[v.x][v.y - 1] == map[v.x][v.y] + 1) {
            try queue.writeItem(.{ .x = v.x, .y = v.y - 1 });
        }
        if (v.y + 1 < map.len and map[v.x][v.y + 1] == map[v.x][v.y] + 1) {
            try queue.writeItem(.{ .x = v.x, .y = v.y + 1 });
        }
    }
    return nines.slice().len;
}

fn read_input() ![rows][cols]u8 {
    var linesIter = std.mem.tokenizeAny(u8, input, "\n");
    var map: [rows][cols]u8 = undefined;
    var rowIdx: u64 = 0;
    while (linesIter.next()) |row| {
        var colIdx: u64 = 0;
        for (row) |num| {
            map[rowIdx][colIdx] = num;
            colIdx += 1;
        }
        rowIdx += 1;
    }
    return map;
}
