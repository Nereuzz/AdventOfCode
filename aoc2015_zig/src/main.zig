const std = @import("std");
const day1 = @import("day1/day1.zig");
const day2 = @import("day2/day2.zig");
const day4 = @import("day4/day4.zig");

pub fn main() !void {
    try day1.main();
    try day2.main();
    try day4.main();
}
