const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

pub fn main() !void {
    const sol1 = try p1();
    const sol2 = try p2();

    print("Day 11:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn p1() !u64 {
    var stones = try std.BoundedArray([]u8, 100000).init(0);
    var stonesIter = std.mem.tokenizeAny(u8, input, " \n");
    while (stonesIter.next()) |stone| {
        var buf = [_]u8{0} ** 100;
        std.mem.copyForwards(u8, &buf, stone);
        var stoneLen: u64 = 0;
        for (buf, 0..) |char, idx| {
            if (char == 0) {
                stoneLen = idx;
                break;
            }
        }
        try stones.append(buf[0..stoneLen]);
    }

    const blinks: u64 = 1;
    for (0..blinks) |i| {
        _ = i;
        for (stones.slice(), 0..) |stone, stoneIdx| {
            if (rule1(stone)) {
                print("Rule 1 applies to stone {s}\n", .{stone});
                try stones.set(stoneIdx, 1);
            } else if (rule2(stone)) {
                print("Rule 2 applies to stone {s}\n", .{stone});
            } else {
                print("Else\n", .{});
            }
        }
    }
    return 0;
}

fn rule1(stone: []const u8) bool {
    const value = std.fmt.parseInt(u8, stone, 10) catch return false;
    return value == 0;
}

fn rule2(stone: []const u8) bool {
    return stone.len % 2 == 0;
}

fn p2() !u64 {
    return 0;
}
