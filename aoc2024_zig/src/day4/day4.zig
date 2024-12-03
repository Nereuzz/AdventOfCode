const std = @import("std");
const input = @embedFile("test.txt");
const print = std.debug.print;

pub fn main() !void {
    print("Day 4:\n", .{});
    const sol1 = p1();
    print("Part 1: {}\n", .{sol1});
    const sol2 = p2();
    print("Part 2: {}\n", .{sol2});
}

fn p1() u64 {
    return 0;
}

fn p2() u64 {
    return 0;
}
