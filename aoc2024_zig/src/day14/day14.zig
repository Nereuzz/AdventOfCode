const std = @import("std");
const regex = @import("mvzr.zig");
const print = std.debug.print;
const input = @embedFile("test.txt");

const Robot = struct { x: i64, y: i64, vx: i64, vy: i64 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var robots = std.ArrayList(Robot).init(allocator);
    const numbers = regex.compile("[-]?(\\d+)").?;
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var iter = numbers.iterator(line);
        const px = try std.fmt.parseInt(i64, iter.next().?.slice, 10);
        const py = try std.fmt.parseInt(i64, iter.next().?.slice, 10);
        const vx = try std.fmt.parseInt(i64, iter.next().?.slice, 10);
        const vy = try std.fmt.parseInt(i64, iter.next().?.slice, 10);
        const rob: Robot = .{ .x = px, .y = py, .vx = vx, .vy = vy };
        try robots.append(rob);
    }

    const sol1 = try p1(robots.items);

    print("Day 14:\nPart 1:{}\n", .{sol1});
}

fn p1(robs: []Robot, width: u8, height: u8, seconds: u8) !u64 {
    for (0..seconds) {
        for (robs) |rob| {
            var newX = rob.c + rob.vx;
            var newY = rob.c + rob.vy;
            if (newX >)
}
}
}
