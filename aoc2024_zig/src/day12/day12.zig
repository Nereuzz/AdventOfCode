const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    var iter = std.mem.tokenizeAny(u8, input, "\n");

    var rowIdx: u64 = 0;
    while (iter.next()) |row| : (rowIdx += 1) {
        try grid.insert(rowIdx, row);
    }

    const sol1 = try p1(allocator, grid.items);

    print("Day12:\nPart 1: {}\n", .{sol1});
}

const Point = packed struct { row: usize, col: usize, plant: u8 };
const Region = []Point;

fn p1(allocator: std.mem.Allocator, grid: [][]const u8) !u64 {
    var visited = std.ArrayList(Point).init(allocator);
    defer visited.deinit();
    var regions = std.ArrayList(Region).init(allocator);
    defer regions.deinit();

    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (std.mem.indexOf(Point, visited.items, &[_]Point{.{ .row = rowIdx, .col = colIdx, .plant = col }})) |_| {
                continue;
            }
            const region = try bfs(.{ .row = rowIdx, .col = colIdx, .plant = col }, allocator, grid, &visited);
            defer allocator.free(region);
            print("Region: {any}\n", .{region});
            try regions.append(region);
        }
    }

    return 0;
}

fn bfs(root: Point, allocator: std.mem.Allocator, grid: [][]const u8, visited: *std.ArrayList(Point)) !Region {
    var region = std.ArrayList(Point).init(allocator);
    var queue = std.fifo.LinearFifo(Point, .Dynamic).init(allocator);
    defer {
        region.deinit();
        queue.deinit();
    }

    try queue.writeItem(root);
    while (queue.readItem()) |v| {
        if (std.mem.indexOf(Point, visited.items, &[_]Point{v})) |_| {
            continue;
        }
        try visited.append(v);

        if (v.plant == root.plant) {
            try region.append(v);
        }

        // Right
        if (v.col + 1 < grid[0].len and v.plant == grid[v.row][v.col + 1])
            try queue.writeItem(point(v.row, v.col + 1, v.plant));
        // Left
        if (v.col != 0 and v.plant == grid[v.row][v.col - 1])
            try queue.writeItem(point(v.row, v.col - 1, v.plant));
        // Up
        if (v.row != 0 and v.plant == grid[v.row - 1][v.col])
            try queue.writeItem(point(v.row - 1, v.col, v.plant));
        // Down
        if (v.row + 1 < grid.len and v.plant == grid[v.row + 1][v.col])
            try queue.writeItem(point(v.row + 1, v.col, v.plant));
    }

    return allocator.dupe(Point, region.items);
}

fn point(row: usize, col: usize, plant: u8) Point {
    return .{ .row = row, .col = col, .plant = plant };
}
