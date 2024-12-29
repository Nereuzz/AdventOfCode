const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    _ = allocator;

    var bytes = try std.BoundedArray([2]u8, 1000).init(0);

    var linesIter = std.mem.splitScalar(u8, input, '\n');
    while (linesIter.next()) |line| {
        if (line.len == 0) break;
        var coords = std.mem.splitScalar(u8, line, ',');
        const col = try std.fmt.parseInt(u8, coords.next().?, 10);
        const row = try std.fmt.parseInt(u8, coords.next().?, 10);
        try bytes.append([2]u8{ row, col });
    }

    const sol1 = try p1(bytes.slice());
    const sol2 = try p2();

    print("Day 18:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

const Point = struct {.row: u8, .col: u8};

fn p1(bytes: [][2]u8) !u64 {
    var grid = [_][7]u8{[_]u8{'.'} ** 7} ** 7;
    for (0..12) |i| {
        const byteCoords = bytes[i];
        grid[byteCoords[0]][byteCoords[1]] = '#';
    }
    for (grid) |row| print("haha: {s}\n", .{row});
    return 0;
}

fn bfs(grid: [][]u8, s: Point) u64 {
    var q = std.fifo.LinearFifo(u8, .{ .Static = 1000 }).init();
    
}

fn p2() !u64 {
    return 0;
}
