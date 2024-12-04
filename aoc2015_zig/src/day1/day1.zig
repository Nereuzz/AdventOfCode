const std = @import("std");
const input = @embedFile("input.txt");
const print = std.debug.print;

pub fn main() !void {
    print("Day1:\n", .{});
    const sol1 = p1();
    print("Part 1: {}\n", .{sol1});
    const sol2 = p2();
    print("Part 2: {}\n\n", .{sol2});
}

fn p2() u64 {
    var result: i64 = 0;
    for (input, 0..) |char, idx| {
        if (char == '(') {
            result += 1;
        }
        if (char == ')') {
            result -= 1;
        }
        if (result < 0) {
            return idx + 1;
        }
    }
    return 0;
}

fn p1() i64 {
    var result: i64 = 0;
    for (input) |char| {
        if (char == '(') {
            result += 1;
        }
        if (char == ')') {
            result -= 1;
        }
    }
    return result;
}
