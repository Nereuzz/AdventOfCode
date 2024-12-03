const std = @import("std");
const print = std.debug.print;
const day1 = @import("day1/day1.zig");
const day2 = @import("day2/day2.zig");
const day3 = @import("day3/day3.zig");

pub fn main() !void {
    print("Day 1:\n", .{});
    try day1.main();
    print("\n", .{});

    print("Day 2:\n", .{});
    try day2.main();
    print("\n", .{});

    try day3.main();
}
