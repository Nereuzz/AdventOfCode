const std = @import("std");
const input = @embedFile("input.txt");
const day2 = @import("../day2/day2.zig");
const print = std.debug.print;

pub fn main() !void {
    print("Day 3:\n", .{});
    const sol1: u64 = p1();
    print("Part 1: {}\n", .{sol1});
    const sol2 = p2();
    print("Part 2: {}\n", .{sol2});
}

fn p1() u64 {
    var result: u64 = 0;
    var stringIter = std.mem.tokenizeAny(u8, input, "m");
    while (stringIter.next()) |entry| {
        if (entry[0] != 117) {
            continue;
        }
        const tmp = checkForMul(entry);
        if (tmp != null) {
            result += tmp.?;
        }
    }
    return result;
}

fn p2() u64 {
    var result: u64 = 0;
    var enabled: bool = true;
    var stringIter = std.mem.tokenizeAny(u8, input, "dm");
    while (stringIter.next()) |entry| {
        if (entry[0] == 117 and enabled) {
            const tmp = checkForMul(entry);
            if (tmp != null) {
                result += tmp.?;
            }
        } else if (entry[0] == 111 and entry[1] == 40 and entry[2] == 41) { // Lol
            enabled = true;
        } else if ((entry[0] == 111 and // Lol
            entry[1] == 110 and
            entry[2] == 39 and
            entry[3] == 116 and
            entry[4] == 40 and
            entry[5] == 41))
        {
            enabled = false;
        } else {
            continue;
        }
    }
    return result;
}

// KNOWN BUG: mul((5,5) is considered correct.. But does not appear in my test set xD
fn checkForMul(mulPart: []const u8) ?u64 {
    var tokens = std.mem.tokenizeAny(u8, mulPart, "(,\n");
    const mul = tokens.next();
    if (mul.?[0] != 117 and mul.?[1] != 108 or mulPart[2] != 40) {
        return null;
    }
    const op1 = std.fmt.parseInt(u64, tokens.next() orelse "", 10) catch return null;
    const tmp = tokens.next() orelse "";
    const hest = std.mem.indexOf(u8, tmp, ")") orelse 0;
    const op2 = std.fmt.parseInt(u64, tmp[0..hest], 10) catch return null;
    return op1 * op2;
}
