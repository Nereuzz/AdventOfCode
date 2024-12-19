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
    fromDir: ?Direction = null,

    fn getCoord(self: Point) [2]u64 {
        return [2]u64{ self.row, self.col };
    }
};

const Deer = struct {
    row: u64,
    col: u64,
    dir: Direction,
};

const Direction = enum { Up, Right, Down, Left, Unknown };
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
            point.direction = Direction.Unknown;
            point.fromDir = Direction.Unknown;
            if (col == 'S') point.direction = Direction.Right;
            try tree.append(point);
        }
    }

    const source: Point = .{
        .row = grid.len - 2,
        .col = 1,
        .v = 'S',
        .direction = Direction.Right,
        .fromDir = Direction.Unknown,
    };
    return Dijkstra(grid, &tree, source, allocator);
}

const distancesType = std.AutoHashMap([2]u64, u64);
const prevsType = std.AutoHashMap([2]u64, std.ArrayList(Point));
fn Dijkstra(grid: [][]u8, tree: *std.ArrayList(Point), source: Point, allocator: std.mem.Allocator) !u64 {
    var distances = distancesType.init(allocator);
    var prevs = prevsType.init(allocator);
    defer {
        distances.deinit();

        // var prevIter = prevs.valueIterator();
        // while (prevIter.next()) |item| {
        //     // for (item.items) |p| allocator.destroy(p);
        //     allocator.destroy(item);
        // }

        // prevs.clearAndFree();
    }

    for (tree.items) |p| {
        try distances.put(p.getCoord(), std.math.maxInt(u64) - 20000);
    }
    try distances.put(source.getCoord(), 0);

    while (tree.items.len > 0) {
        // for (grid, 0..) |row, idx| {
        //     print("{s}   {}\n", .{ row, idx });
        // }
        // print("\n\n", .{});
        const uIdx = GetNextVertex(tree, distances);
        const u: Point = tree.orderedRemove(uIdx);
        if (u.v == 'E') continue;

        var neighbours = [_]Point{undefined} ** 4;
        const up: Point = .{ .row = u.row - 1, .col = u.col, .v = grid[u.row - 1][u.col], .direction = Direction.Up };
        const down: Point = .{ .row = u.row + 1, .col = u.col, .v = grid[u.row + 1][u.col], .direction = Direction.Down };
        const left: Point = .{ .row = u.row, .col = u.col - 1, .v = grid[u.row][u.col - 1], .direction = Direction.Left };
        const right: Point = .{ .row = u.row, .col = u.col + 1, .v = grid[u.row][u.col + 1], .direction = Direction.Right };
        neighbours[0] = up;
        neighbours[2] = down;
        neighbours[3] = left;
        neighbours[1] = right;

        for (neighbours) |v| {
            if (v.v == '#' or (u.fromDir == GetOppositeDirection(v.direction))) continue;
            const costToV = CostToV(u, v, distances);
            const oldDist = distances.get(v.getCoord()).?;
            const newDist = distances.get(u.getCoord()).? + costToV;
            if (newDist <= oldDist) {
                var future = &tree.items[GetVertexIdx(tree, v)];
                const hmm = try prevs.getOrPut(future.getCoord());
                if (hmm.found_existing) {
                    try hmm.value_ptr.*.append(u);
                } else {
                    var p = std.ArrayList(Point).init(allocator);
                    try p.append(u);
                    try prevs.put(future.getCoord(), p);
                }
                future.direction = v.direction;
                future.fromDir = v.direction;
                try distances.put(v.getCoord(), newDist);
                grid[v.row][v.col] = '@';
                if (v.v == 'E') return distances.get([2]u64{ 1, grid[0].len - 2 }).?;
            }
        }
    }
    print("\n\n", .{});

    print("E prevs: {any}\n", .{prevs.get([2]u64{ 9, 2 }).?.items});

    return distances.get([2]u64{ 1, grid[0].len - 2 }).?;
}

fn GetOppositeDirection(d: Direction) Direction {
    return switch (d) {
        Direction.Up => Direction.Down,
        Direction.Down => Direction.Up,
        Direction.Left => Direction.Right,
        Direction.Right => Direction.Left,
        else => unreachable,
    };
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

fn GetVertexIdx(tree: *std.ArrayList(Point), u: Point) u64 {
    for (tree.items, 0..) |v, idx| {
        if (std.mem.eql(u64, &v.getCoord(), &u.getCoord())) return idx;
    }
    return std.math.maxInt(u64);
}

fn CostToV(u: Point, v: Point, distances: distancesType) u64 {
    _ = distances;
    if (u.direction == v.direction) return 1;
    return 1001;
}
