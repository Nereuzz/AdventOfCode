const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

pub fn main() !void {
    print("Day 2:\n", .{});
    const sol1 = p1();
    print("Part 1: {}\n", .{sol1});
    const sol2 = p2();
    print("Part 2: {}\n", .{sol2});
}

fn p1() u64 {
    var presents = std.mem.tokenizeAny(u8, input, "\n");
    var result: u64 = 0;
    while (presents.next()) |present| {
        result += wrappingForPresent(present[0..]);
    }
    return result;
}

fn p2() u64 {
    var presents = std.mem.tokenizeAny(u8, input, "\n");
    var result: u64 = 0;
    while (presents.next()) |present| {
        result += ribbonForPresent(present[0..]);
    }
    return result;
}

fn ribbonForPresent(present: []const u8) u64 {
    var dims = std.mem.tokenizeAny(u8, present, "x");
    const l = std.fmt.parseInt(u64, dims.next().?, 10) catch undefined;
    const w = std.fmt.parseInt(u64, dims.next().?, 10) catch undefined;
    const h = std.fmt.parseInt(u64, dims.next().?, 10) catch undefined;
    var lowest: u64 = 10000;
    var secLowest: u64 = 10000;
    const damn: [3]u64 = [3]u64{ l, w, h };
    for (damn) |dim| {
        if (dim < secLowest) {
            if (dim < lowest) {
                secLowest = lowest;
                lowest = dim;
                continue;
            }
            secLowest = dim;
        }
    }

    return 2 * lowest + 2 * secLowest + l * w * h;
}

fn wrappingForPresent(present: []const u8) u64 {
    var dims = std.mem.tokenizeAny(u8, present, "x");
    const l = std.fmt.parseInt(u64, dims.next().?, 10) catch undefined;
    const w = std.fmt.parseInt(u64, dims.next().?, 10) catch undefined;
    const h = std.fmt.parseInt(u64, dims.next().?, 10) catch undefined;
    const lw: u64 = l * w;
    const wh: u64 = w * h;
    const hl: u64 = h * l;

    var lowest: u64 = 10000;
    const damn: [3]u64 = [3]u64{ lw, wh, hl };
    for (damn) |dim| {
        if (dim < lowest) {
            lowest = dim;
        }
    }

    return 2 * lw + 2 * wh + 2 * hl + lowest;
}
