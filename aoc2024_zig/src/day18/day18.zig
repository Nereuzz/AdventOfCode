const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

const bytesToDrop = 1024;
const maxBytes = 3450;
const rows: usize = 71;
const cols: usize = 71;

const Point = struct {
    row: u8,
    col: u8,
    dist: u64,

    fn compare(_: void, a: Point, b: Point) std.math.Order {
        return std.math.order(a.dist, b.dist);
    }

    fn coords(a: Point) [2]u8 {
        return .{ a.row, a.col };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var bytes = try std.BoundedArray([2]u8, 5000).init(0);

    var linesIter = std.mem.splitScalar(u8, input, '\n');
    while (linesIter.next()) |line| {
        if (line.len == 0) break;
        var coords = std.mem.splitScalar(u8, line, ',');
        const col = try std.fmt.parseInt(u8, coords.next().?, 10);
        const row = try std.fmt.parseInt(u8, coords.next().?, 10);
        try bytes.append([2]u8{ row, col });
    }
    linesIter.reset();

    const sol1 = try p1(bytes.slice(), allocator);
    const sol2 = try p2(bytes.slice(), allocator);
    var ans2 = bytes.buffer[sol2 - 1];
    std.mem.reverse(u8, &ans2);

    print("Day 18:\nPart 1: {}\nPart 2: {},{}\n", .{ sol1, ans2[0], ans2[1] });
}

fn p1(bytes: [][2]u8, allocator: std.mem.Allocator) !u64 {
    var grid = [_][cols]u8{([_]u8{'.'} ** cols)} ** rows;
    for (0..bytesToDrop) |i| {
        const byteCoords = bytes[i];
        grid[byteCoords[0]][byteCoords[1]] = '#';
    }

    return dijkstra(&grid, .{ .row = 0, .col = 0, .dist = 0 }, allocator);
}

fn p2(bytes: [][2]u8, allocator: std.mem.Allocator) !u64 {
    var low: u64 = 0;
    var high: u64 = bytes.len - 1;
    var ans: u64 = bytes.len;
    while (low <= high) {
        const mid = (low + high) >> 1;
        var grid = [_][cols]u8{([_]u8{'.'} ** cols)} ** rows;
        for (0..mid) |i| {
            const byteCoords = bytes[i];
            grid[byteCoords[0]][byteCoords[1]] = '#';
        }
        const dijkRes = try dijkstra(&grid, .{ .row = 0, .col = 0, .dist = 0 }, allocator);
        if (dijkRes >= 9999) {
            ans = mid;
            high = mid - 1;
        } else {
            low = mid + 1;
        }
    }
    return ans;
}

fn dijkstra(grid: *[rows][cols]u8, s: Point, allocator: std.mem.Allocator) !u64 {
    var dist = std.AutoArrayHashMap([2]u8, u64).init(allocator);
    var prev = std.AutoHashMap([2]u8, ?[2]u8).init(allocator);
    var queue = std.PriorityQueue(Point, void, Point.compare).init(allocator, {});
    defer {
        dist.deinit();
        prev.deinit();
        queue.deinit();
    }

    for (grid, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == '#') continue;
            const v: Point = .{ .row = @intCast(rowIdx), .col = @intCast(colIdx), .dist = 9999 };
            try queue.add(v);
            try dist.put(v.coords(), 9999);
            try prev.put(v.coords(), null);
        }
    }
    try queue.add(s);

    while (queue.items.len > 0) {
        const u = queue.remove();
        const neighbours = try GetNeighbours(u, grid, allocator);
        defer allocator.free(neighbours);

        for (neighbours) |p| {
            if (p) |v| {
                const oldDist = dist.get(v.coords()).?;
                const newDist = u.dist + 1;
                if (newDist < oldDist) {
                    const newV: Point = .{ .row = v.row, .col = v.col, .dist = newDist };
                    try dist.put(v.coords(), newDist);
                    try queue.update(.{ .row = v.row, .col = v.col, .dist = oldDist }, newV);
                    try prev.put(v.coords(), u.coords());
                }
            }
        }
    }

    return dist.get(.{ rows - 1, cols - 1 }).?;
}

fn GetNeighbours(u: Point, grid: *[rows][cols]u8, allocator: std.mem.Allocator) ![]?Point {
    const up: ?Point = if (u.row == 0) null else .{
        .row = u.row - 1,
        .col = u.col,
        .dist = 0,
    };
    const down: ?Point = if (u.row == grid[0].len - 1) null else .{
        .row = u.row + 1,
        .col = u.col,
        .dist = 0,
    };
    const left: ?Point = if (u.col == 0) null else .{
        .row = u.row,
        .col = u.col - 1,
        .dist = 0,
    };
    const right: ?Point = if (u.col == grid.len - 1) null else .{
        .row = u.row,
        .col = u.col + 1,
        .dist = 0,
    };

    var lol = try allocator.alloc(?Point, 4);
    lol[0] = if (up) |v| if (grid[v.row][v.col] != '#') v else null else null;
    lol[1] = if (down) |v| if (grid[v.row][v.col] != '#') v else null else null;
    lol[2] = if (left) |v| if (grid[v.row][v.col] != '#') v else null else null;
    lol[3] = if (right) |v| if (grid[v.row][v.col] != '#') v else null else null;
    return lol;
}
