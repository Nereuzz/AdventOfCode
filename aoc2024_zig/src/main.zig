const std = @import("std");
const input = @embedFile("test.txt");

pub fn main() !void {
    const tokenized = std.mem.tokenizeAny(u8, input, "\n");

    std.debug.print("{}", .{hest});
}
