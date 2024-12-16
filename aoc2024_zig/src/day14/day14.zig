const std = @import("std");
const regex = @import("mvzr.zig");
const print = std.debug.print;
const input = @embedFile("input.txt");

const Robot = struct {
    x: i64,
    y: i64,
    vx: i64,
    vy: i64,

    fn lessThan(_: void, a: Robot, b: Robot) bool {
        if (a.y == b.y)
            return a.x < b.x;
        return a.y < b.y;
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
    const sol2 = try p2(robots.items, 101, 103, allocator);

    print("Day 14:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn p2(robs: []Robot, width: i64, height: i64, allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    const max: u64 = @intCast(width * height);
    for (101..max) |seconds| { // First 100 iterations done by part 1
        for (robs, 0..) |rob, idx| {
            robs[idx].x = @mod(rob.x + rob.vx, width);
            robs[idx].y = @mod(rob.y + rob.vy, height);
        }

        std.mem.sort(Robot, robs, {}, Robot.lessThan);

        for (robs, 0..) |_, idx| {
            if (idx > 500 - 12 or !(robs[idx].y == robs[idx + 1].y and
                robs[idx].y == robs[idx + 2].y and
                robs[idx].y == robs[idx + 3].y and
                robs[idx].y == robs[idx + 4].y and
                robs[idx].y == robs[idx + 5].y and
                robs[idx].x + 1 == robs[idx + 1].x and
                robs[idx].x + 2 == robs[idx + 2].x and
                robs[idx].x + 3 == robs[idx + 3].x and
                robs[idx].x + 4 == robs[idx + 4].x and
                robs[idx].x + 5 == robs[idx + 5].x and
                robs[idx].x + 6 == robs[idx + 6].x))
            {
                continue;
            } else {
                // for (0..103) |row| { // Beautiful print <3
                //     for (0..101) |col| {
                //         var robStart: usize = 0;
                //         var robPrinted = false;
                //         for (robs[robStart..], 0..) |rob, idxp| {
                //             if (rob.y > row) break;
                //             if (rob.x == col and rob.y == row and !robPrinted) {
                //                 print("R", .{});
                //                 robPrinted = true;
                //                 robStart = idxp;
                //                 continue;
                //             }
                //         }
                //         if (robPrinted) {
                //             robPrinted = false;
                //             continue;
                //         }
                //         print(".", .{});
                //     }
                //     print("\n", .{});
                // } // End of beautiful print
                return seconds;
            }
        }
    }
    return 99999;
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
