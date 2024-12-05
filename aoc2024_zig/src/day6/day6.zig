const std = @import("std");
const input = @embedFile("test.txt");
const print = std.debug.print;

pub fn main() !void {
    print("Day 6:\n", .{});
    const sol1 = try p1();
    print("Part 1: {}\n", .{sol1});
    const sol2 = try p2();
    print("Part 2: {}", .{sol2});
}

fn p1() !u64 {
    return 0;
}

fn p2() !u64 {
    return 0;
}
