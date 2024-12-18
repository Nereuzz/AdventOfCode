const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var grid = std.ArrayList([]u8).init(allocator);
    defer {
        for (grid.items) |row| allocator.free(row);
        grid.clearAndFree();
    }

    var linesIter = std.mem.tokenizeScalar(u8, input, '\n');
    while (linesIter.next()) |line| {
        const row = try allocator.dupe(u8, line);
        try grid.append(row);
    }

    for (grid.items, 0..) |row, idx| {
        print("{s} {}\n", .{ row, idx });
    }

    const sol1 = try p1(grid.items, allocator);

    print("Day 16:Part 1: {}\n", .{sol1});
}

const Point = struct {
    row: u64,
    col: u64,
    v: u8,
    direction: Direction,

    fn getCoord(self: Point) [2]u64 {
        return [2]u64{ self.row, self.col };
    }
};

const Deer = struct {
    row: u64,
    col: u64,
    dir: Direction,
};

const Direction = enum { Up, Right, Down, Left };
fn p1(grid: [][]u8, allocator: std.mem.Allocator) !u64 {
    var tree = std.ArrayList(Point).init(allocator);
    defer tree.deinit();

    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == '#') continue;
            var point: Point = undefined;
            point.row = rowIdx;
            point.col = colIdx;
            point.v = col;
            if (col == 'S') point.direction = Direction.Right;
            try tree.append(point);
        }
    }

    const source: Point = .{ .row = 13, .col = 1, .v = 'S', .direction = Direction.Right };
    return Dijkstra(grid, &tree, source, allocator);
}
const distancesType = std.AutoHashMap([2]u64, u64);
fn Dijkstra(grid: [][]u8, tree: *std.ArrayList(Point), source: Point, allocator: std.mem.Allocator) !u64 {
    var distances = distancesType.init(allocator);
    defer distances.deinit();

    for (tree.items) |p| {
        try distances.put(p.getCoord(), std.math.maxInt(u64));
    }
    try distances.put(source.getCoord(), 0);

    while (tree.items.len > 0) {
        const uIdx = GetNextVertex(tree, distances);
        const u: Point = tree.orderedRemove(uIdx);

        var neighbours = [_]Point{undefined} ** 4;
        const up: Point = .{ .row = u.row - 1, .col = u.col, .v = grid[u.row - 1][u.col], .direction = undefined };
        const down: Point = .{ .row = u.row + 1, .col = u.col, .v = grid[u.row + 1][u.col], .direction = undefined };
        const left: Point = .{ .row = u.row, .col = u.col - 1, .v = grid[u.row][u.col - 1], .direction = undefined };
        const right: Point = .{ .row = u.row, .col = u.col + 1, .v = grid[u.row][u.col + 1], .direction = undefined };
        neighbours[0] = up;
        neighbours[2] = down;
        neighbours[3] = left;
        neighbours[1] = right;

        for (neighbours, 0..) |v, dir| {
            if (v.v == '#') continue;
            const d: Direction = @enumFromInt(dir);
            const newDist = distances.get(u.getCoord()).? + CostToV(u, d);
            if (newDist < distances.get(v.getCoord()).?) {
                try distances.put(v.getCoord(), newDist);
            }
        }
    }

    return distances.get([2]u64{ 1, 13 }).?;
}

fn GetNextVertex(tree: *std.ArrayList(Point), distances: distancesType) u64 {
    var min: u64 = 0;
    for (tree.items, 0..) |u, idx| {
        const dist = distances.get(u.getCoord()).?;
        if (dist < distances.get(tree.items[min].getCoord()).?) {
            min = idx;
        }
    }
    return min;
}

fn CostToV(source: Point, direction: Direction) u64 {
    print("source direction: {any} --- direction: {any}\n", .{ source.direction, direction });
    if (source.direction == direction) return 1;
    return 1001;
}
