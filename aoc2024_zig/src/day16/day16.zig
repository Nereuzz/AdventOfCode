const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");
const Point = struct { row: u64, col: u64, d: u64, n: []u8, v:u8 };
const Direction = enum { Up, Right, Down, Left };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var grid = std.ArrayList([]Point).init(allocator);
    defer {
        for (grid.items) |row| {
            for (row) |p| allocator.free(p);
            allocator.free(row);
        }
        grid.clearAndFree();
    }

    var linesIter = std.mem.splitScalar(u8, input, '\n');
    while (linesIter.next(), 0..) |line, rowIdx| {
        const row = try allocator.allocate(u8, line.len);
        for (line, 0..) |c,colIdx| {
            var point: Point = undefined;
            switch {c} {
                '.' => {
                }
            }
        }
    }

    for (grid.items) |row| {
        print("{s}\n", .{row});
    }

    const sol1 = try p1(grid.items, allocator);

    print("Day 16:Part 1: {}\n", .{sol1});
}

fn p1(grid: [][]u8, allocator: std.mem.Allocator) !u64 {
    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {}
    }

    return 0;
}
