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

    // const sol1 = try p1(allocator, grid.items);
    const sol2 = try p2(allocator, grid.items);

    print("Day12:\nPart 1: {}\nPart 2:\n", .{sol2});
}

const Point = packed struct { row: usize, col: usize, plant: u8 };
const Region = []Point;

fn p1(allocator: std.mem.Allocator, grid: [][]const u8) !u64 {
    var visited = std.ArrayList(Point).init(allocator);
    defer visited.deinit();
    var regions = std.ArrayList(Region).init(allocator);
    defer {
        for (regions.items) |region| allocator.free(region);
        regions.deinit();
    }

    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (std.mem.indexOf(Point, visited.items, &[_]Point{.{ .row = rowIdx, .col = colIdx, .plant = col }})) |_| continue;
            const region = try bfs(.{ .row = rowIdx, .col = colIdx, .plant = col }, allocator, grid, &visited);
            try regions.append(region);
        }
    }

    var result: usize = 0;
    for (regions.items) |region| {
        const area = region.len;
        const perimeter = try getPerimeter(region, grid);
        result += area * perimeter;
    }

    return result;
}

fn p2(allocator: std.mem.Allocator, grid: [][]const u8) !u64 {
    var visited = std.ArrayList(Point).init(allocator);
    defer visited.deinit();
    var regions = std.ArrayList(Region).init(allocator);
    defer {
        for (regions.items) |region| allocator.free(region);
        regions.deinit();
    }

    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (std.mem.indexOf(Point, visited.items, &[_]Point{.{ .row = rowIdx, .col = colIdx, .plant = col }})) |_| continue;
            const region = try bfs(.{ .row = rowIdx, .col = colIdx, .plant = col }, allocator, grid, &visited);
            try regions.append(region);
        }
    }

    var result: u64 = 0;
    for (regions.items) |region| {
        // print("Trying: {any}\n", .{region});
        const tmp = try find_corners(region, grid, allocator);
        print("Tmp: {}\n", .{tmp});
        result += tmp;
    }

    return result;
}

fn UpOuterRight(v: Point, grid: [][]const u8) bool {
    return (v.col + 1 == grid[0].len and v.row == 0) or
        (v.plant != grid[v.row][v.col + 1] and
        v.plant != grid[v.row - 1][v.col + 1] and
        v.plant != grid[v.row - 1][v.col]);
}

fn UpOuterLeft(v: Point, grid: [][]const u8) bool {
    return (v.col == 0 and v.row == 0) or
        (v.plant != grid[v.row - 1][v.col] and
        v.plant != grid[v.row - 1][v.col - 1] and
        v.plant != grid[v.row][v.col - 1]);
}

fn DownOuterLeft(v: Point, grid: [][]const u8) bool {
    return (v.col == 0 and v.row + 1 == grid.len) or
        (v.plant != grid[v.row][v.col - 1] and
        (v.plant != grid[v.row + 1][v.col - 1]) and
        v.plant != grid[v.row + 1][v.col]);
}

fn DownOuterRight(v: Point, grid: [][]const u8) bool {
    return (v.col + 1 == grid[0].len and v.row + 1 == grid.len) or
        (v.plant != grid[v.row + 1][v.col] and
        v.plant != grid[v.row + 1][v.col] and
        v.plant != grid[v.row][v.col + 1]);
}

fn find_corners(region: Region, grid: [][]const u8, allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    var result: u64 = 0;
    var tmp: u64 = 0;
    for (region) |v| {
        print("Checking point: {}\n", .{v});
        if (UpOuterLeft(v, grid)) tmp += 1;
        if (UpOuterRight(v, grid)) tmp += 1;
        if (DownOuterLeft(v, grid)) tmp += 1;
        if (DownOuterRight(v, grid)) tmp += 1;
        print("Result for point {}\n", .{tmp});
        result += tmp;
        tmp = 0;
    }
    return result;
}

fn getPerimeter(region: []Point, grid: [][]const u8) !u64 {
    var result: usize = 0;
    for (region) |v| {
        // Right
        if (v.col + 1 == grid[0].len or v.plant != grid[v.row][v.col + 1]) result += 1;
        // Left
        if (v.col == 0 or v.plant != grid[v.row][v.col - 1]) result += 1;
        // Up
        if (v.row == 0 or v.plant != grid[v.row - 1][v.col]) result += 1;
        // Down
        if (v.row + 1 == grid.len or v.plant != grid[v.row + 1][v.col]) result += 1;
    }
    return result;
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
        if (std.mem.indexOf(Point, visited.items, &[_]Point{v})) |_| continue;

        try visited.append(v);
        if (v.plant == root.plant) try region.append(v);

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
