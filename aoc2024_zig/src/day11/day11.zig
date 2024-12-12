const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
const mapType = std.StringHashMap(u64);

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var map = mapType.init(allocator);
    defer map.deinit();

    var sol1: u64 = 0;
    var sol2: u64 = 0;

    var stonesIter = std.mem.tokenizeAny(u8, input, " \n");
    while (stonesIter.next()) |stone| {
        sol1 += try solveStone(stone, 25, &map, allocator);
        sol2 += try solveStone(stone, 75, &map, allocator);
    }

    print("Day 11:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn solveStone(stone: []const u8, blinks: comptime_int, map: *mapType, allocator: @TypeOf(std.heap.page_allocator)) !u64 {
    if (blinks == 0) {
        return 1;
    }

    const key = try std.fmt.allocPrint(allocator, "{}:{s}", .{ blinks, stone });
    if (map.get(key)) |result| {
        return result;
    }

    var result: u64 = 0;
    if (rule1(stone)) {
        result = try solveStone(&[1]u8{'1'}, blinks - 1, map, allocator);
    } else if (rule2(stone)) {
        const left = stone[0 .. stone.len / 2];
        result = try solveStone(left, blinks - 1, map, allocator);

        var right = stone[stone.len / 2 ..];
        const parsedRight = std.fmt.parseInt(u64, right, 10) catch 1;
        if (parsedRight == 0) {
            result += try solveStone(&[1]u8{'0'}, blinks - 1, map, allocator);
        } else {
            var idx: u64 = 0;
            for (right, 0..) |char, idxx| {
                if (char == '0') {
                    continue;
                }
                idx = idxx;
                break;
            }
            right = right[idx..];
            result += try solveStone(right, blinks - 1, map, allocator);
        }
    } else {
        const value = try std.fmt.parseInt(u64, stone, 10);
        const newValue = try std.fmt.allocPrint(allocator, "{}", .{value * 2024});
        result = try solveStone(newValue, blinks - 1, map, allocator);
    }

    try map.put(key, result);
    return result;
}

fn rule1(stone: []const u8) bool {
    const value = std.fmt.parseInt(u8, stone, 10) catch return false;
    return value == 0;
}

fn rule2(stone: []const u8) bool {
    return stone.len % 2 == 0;
}
