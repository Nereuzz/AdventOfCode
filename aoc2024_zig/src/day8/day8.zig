const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

pub fn main() !void {
    print("Day 8:\n", .{});
    const sol1 = try p1();
    const sol2 = try p2();

    print("Part 1: {}\nPart2:{}\n", .{ sol1, sol2 });
}

const Antenna = struct { x: u64, y: u54 };

fn p1() !u64 {
    const allocator = std.heap.page_allocator;
    var map = std.AutoHashMap(u8, Antenna).init(allocator);
    defer map.deinit();
    
    var iter = std.mem.tokenizeAny(u8, input, "\n");
    while (iter.next()) |line| {
        for (line, 0..) |char, idx| {
            if (std.ascii.isAlphanumeric(char)) {
                if (map.cont)
}
}
}
}

fn p2() !u64 {
    return 0;
}
