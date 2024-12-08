const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

pub fn main() !void {
    print("Day 8:\n", .{});
    const sol1 = try p1();
    const sol2 = try p2();

    print("Part 1: {}\nPart2:{}\n", .{ sol1, sol2 });
}

fn p1() !u64 {
    return 0;
}

fn p2() !u64 {
    return 0;
}
