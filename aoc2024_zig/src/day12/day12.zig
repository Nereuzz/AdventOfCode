const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var grid = std.ArrayList([]u64).init(allocator);
    defer {
        for (grid.items, 0..) |_, idx| {
            allocator.free(grid.items[idx]);
        }
        grid.deinit();
    }

    var iter = std.mem.tokenizeAny(u8, input, "\n");

    var rowIdx: u64 = 0;
    while (iter.next()) |row| : (rowIdx += 1) {
        var new = std.ArrayList(u64).init(allocator);
        for (row) |plant| {
            try new.append(@intCast(plant));
        }
        try grid.insert(rowIdx, new.items);
    }

    const sol1 = try p1(allocator, grid.items);
    const sol2 = try p2(allocator, grid.items);

    print("Day12:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

const Point = packed struct { row: usize, col: usize, plant: u64 };
const Region = []Point;

fn p1(allocator: std.mem.Allocator, grid: [][]u64) !u64 {
    var visited = std.ArrayList(Point).init(allocator);
    defer visited.deinit();
    var regions = std.ArrayList(Region).init(allocator);
    defer {
        for (regions.items) |region| allocator.free(region);
        regions.deinit();
    }

    var plant: u64 = 0;
    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (std.mem.indexOf(Point, visited.items, &[_]Point{.{ .row = rowIdx, .col = colIdx, .plant = col }})) |_| continue;
            const region = try bfs(.{ .row = rowIdx, .col = colIdx, .plant = col }, plant, allocator, grid, &visited);
            try regions.append(region);
            plant += 1;
        }
    }

    for (regions.items) |region| {
        for (region) |p| grid[p.row][p.col] = p.plant;
    }

    var result: usize = 0;
    for (regions.items) |region| {
        const area = region.len;
        const perimeter = try getPerimeter(region, grid);
        result += area * perimeter;
    }

    return result;
}

fn p2(allocator: std.mem.Allocator, grid: [][]u64) !u64 {
    var visited = std.ArrayList(Point).init(allocator);
    defer visited.deinit();
    var regions = std.ArrayList(Region).init(allocator);
    defer {
        for (regions.items) |region| allocator.free(region);
        regions.deinit();
    }

    var plant: u64 = 0;
    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (std.mem.indexOf(Point, visited.items, &[_]Point{.{ .row = rowIdx, .col = colIdx, .plant = col }})) |_| continue;
            const region = try bfs(.{ .row = rowIdx, .col = colIdx, .plant = col }, plant, allocator, grid, &visited);
            try regions.append(region);
            plant += 1;
        }
    }

    for (regions.items) |region| {
        for (region) |p| grid[p.row][p.col] = p.plant;
    }

    var result: u64 = 0;
    for (regions.items) |region| {
        const sides = try find_corners(region, grid, allocator);
        result += sides * region.len;
    }

    return result;
}

fn UpOuterRight(v: Point, grid: [][]u64) bool {
    const atTop = v.row == 0;
    const atRight = v.col + 1 == grid[0].len;
    if (atTop and atRight) return true;
    if (atTop and !atRight) return v.plant != grid[v.row][v.col + 1];
    if (!atTop and atRight) return v.plant != grid[v.row - 1][v.col];

    return (v.col + 1 == grid[0].len and v.row == 0) or
        (v.plant != grid[v.row][v.col + 1] and
        v.plant != grid[v.row - 1][v.col + 1] and
        v.plant != grid[v.row - 1][v.col]) or
        (v.plant != grid[v.row][v.col + 1] and v.plant != grid[v.row - 1][v.col]);
}

fn UpOuterLeft(v: Point, grid: [][]u64) bool {
    const atTop = v.row == 0;
    const atLeft = v.col == 0;
    if (atLeft and atTop) return true;
    if (atLeft and !atTop) return v.plant != grid[v.row - 1][v.col];
    if (atTop and !atLeft) return v.plant != grid[v.row][v.col - 1];

    return (v.col == 0 and v.row == 0) or
        (v.plant != grid[v.row - 1][v.col] and
        v.plant != grid[v.row - 1][v.col - 1] and
        v.plant != grid[v.row][v.col - 1]) or
        (v.plant != grid[v.row - 1][v.col] and v.plant != grid[v.row][v.col - 1]);
}

fn DownOuterLeft(v: Point, grid: [][]u64) bool {
    const atBottom = v.row + 1 == grid.len;
    const atLeft = v.col == 0;
    if (atLeft and atBottom) return true;
    if (atLeft and !atBottom) return v.plant != grid[v.row + 1][v.col];
    if (!atLeft and atBottom) return v.plant != grid[v.row][v.col - 1];

    return (v.col == 0 and v.row + 1 == grid.len) or
        (v.plant != grid[v.row][v.col - 1] and
        (v.plant != grid[v.row + 1][v.col - 1]) and
        v.plant != grid[v.row + 1][v.col]) or
        (v.plant != grid[v.row][v.col - 1] and v.plant != grid[v.row + 1][v.col]);
}

fn DownOuterRight(v: Point, grid: [][]u64) bool {
    const atBottom = v.row + 1 == grid.len;
    const atRight = v.col + 1 == grid[0].len;
    if (atBottom and atRight) return true;
    if (atBottom and !atRight) return v.plant != grid[v.row][v.col + 1];
    if (!atBottom and atRight) return v.plant != grid[v.row + 1][v.col];

    return (v.col + 1 == grid[0].len and v.row + 1 == grid.len) or
        (v.plant != grid[v.row + 1][v.col] and
        v.plant != grid[v.row + 1][v.col + 1] and
        v.plant != grid[v.row][v.col + 1]) or
        (v.plant != grid[v.row][v.col + 1] and v.plant != grid[v.row + 1][v.col]);
}

fn UpInnerRight(v: Point, grid: [][]u64) bool {
    const atTop = v.row == 0;
    const atRight = v.col + 1 == grid[0].len;
    if (atTop and atRight) return false;
    if (atTop or atRight) return false;

    return (v.plant == grid[v.row][v.col + 1] and
        v.plant != grid[v.row - 1][v.col + 1] and
        v.plant == grid[v.row - 1][v.col]);
}
fn UpInnerLeft(v: Point, grid: [][]u64) bool {
    const atTop = v.row == 0;
    const atLeft = v.col == 0;
    if (atTop and atLeft) return false;
    if (atTop or atLeft) return false;

    return (v.plant == grid[v.row][v.col - 1] and
        v.plant != grid[v.row - 1][v.col - 1] and
        v.plant == grid[v.row - 1][v.col]);
}
fn DownInnerRight(v: Point, grid: [][]u64) bool {
    const atBottom = v.row + 1 == grid.len;
    const atRight = v.col + 1 == grid[0].len;
    if (atBottom and atRight) return false;
    if (atBottom or atRight) return false;

    return (v.plant == grid[v.row + 1][v.col] and
        v.plant != grid[v.row + 1][v.col + 1] and
        v.plant == grid[v.row][v.col + 1]);
}
fn DownInnerLeft(v: Point, grid: [][]u64) bool {
    const atBottom = v.row + 1 == grid.len;
    const atLeft = v.col == 0;
    if (atBottom or atLeft) return false;
    if (atBottom and atLeft) return false;

    return (v.plant == grid[v.row + 1][v.col] and
        v.plant != grid[v.row + 1][v.col - 1] and
        v.plant == grid[v.row][v.col - 1]);
}

fn find_corners(region: Region, grid: [][]u64, allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    var result: u64 = 0;
    var tmp: u64 = 0;
    for (region) |v| {
        if (UpOuterLeft(v, grid)) tmp += 1;
        if (UpOuterRight(v, grid)) tmp += 1;
        if (DownOuterLeft(v, grid)) tmp += 1;
        if (DownOuterRight(v, grid)) tmp += 1;
        if (UpInnerLeft(v, grid)) tmp += 1;
        if (UpInnerRight(v, grid)) tmp += 1;
        if (DownInnerLeft(v, grid)) tmp += 1;
        if (DownInnerRight(v, grid)) tmp += 1;
        result += tmp;
        tmp = 0;
    }
    return result;
}

fn getPerimeter(region: []Point, grid: [][]u64) !u64 {
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

fn bfs(root: Point, plant: u64, allocator: std.mem.Allocator, grid: [][]u64, visited: *std.ArrayList(Point)) !Region {
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
        if (v.plant == root.plant) {
            try region.append(point(v.row, v.col, plant));
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

fn point(row: usize, col: usize, plant: u64) Point {
    return .{ .row = row, .col = col, .plant = plant };
}
