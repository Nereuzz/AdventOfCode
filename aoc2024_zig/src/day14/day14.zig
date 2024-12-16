const std = @import("std");
const regex = @import("mvzr.zig");
const print = std.debug.print;
const input = @embedFile("test.txt");

const Robot = struct {
    x: i64,
    y: i64,
    vx: i64,
    vy: i64,

    fn lessThan(_: void, a: Robot, b: Robot) bool {
        if (a.x == b.x)
            return a.y < b.y;
        return a.x < b.x;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();
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

    const sol1 = try p1(robots.items, 101, 103, 100);
    const sol2 = try p2(robots.items, 11, 7, allocator);

    print("Day 14:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn p2(robs: []Robot, width: i64, height: i64, allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    var seconds: i64 = 1;
    for (robs, 0..) |rob, idx| {
        robs[idx].x = @mod(rob.x + seconds * rob.vx, width);
        robs[idx].y = @mod(rob.y + seconds * rob.vy, height);
    }

    std.mem.sort(Robot, robs, {}, Robot.lessThan);
    for (robs) |rob| print("{any}\n", .{rob});

    seconds += 1;

    return @intCast(seconds);
}

fn p1(robs: []Robot, width: i64, height: i64, seconds: u8) !u64 {
    for (robs, 0..) |rob, idx| {
        robs[idx].x = @mod(rob.x + seconds * rob.vx, width);
        robs[idx].y = @mod(rob.y + seconds * rob.vy, height);
    }

    var q1: u64 = 0;
    var q2: u64 = 0;
    var q3: u64 = 0;
    var q4: u64 = 0;
    const midX = @divExact(width - 1, 2);
    const midY = @divExact(height - 1, 2);
    for (robs) |rob| {
        if (rob.x < midX and rob.y < midY) q1 += 1;
        if (rob.x > midX and rob.y > midY) q2 += 1;
        if (rob.x < midX and rob.y > midY) q3 += 1;
        if (rob.x > midX and rob.y < midY) q4 += 1;
    }

    const result: u64 = q1 * q2 * q3 * q4;
    return result;
}
