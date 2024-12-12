const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

pub fn main() !void {
    const sol1 = 0; //try p1();
    const sol2 = try p2();

    print("Day 11:\nPart 1: {}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn p1() !u64 {
    const allocator = std.heap.page_allocator;
    var stones = std.ArrayList([]u8).init(allocator);
    defer stones.deinit();
    var stonesIter = std.mem.tokenizeAny(u8, input, " \n");

    while (stonesIter.next()) |stone| {
        const buf = try allocator.alloc(u8, stone.len);
        std.mem.copyForwards(u8, buf, stone);
        try stones.append(buf);
    }

    const blinkss = 1;
    for (0..blinkss) |i| {
        _ = i;
        var stoneIdx: u64 = 0;
        const hmm = stones.items;
        for (hmm) |_| {
            if (rule1(stones.items[stoneIdx])) {
                const newStone = try allocator.alloc(u8, 1);
                stones.items[stoneIdx] = newStone;
                std.mem.copyForwards(u8, stones.items[stoneIdx], &[_]u8{'1'});
            } else if (rule2(stones.items[stoneIdx])) {
                const left = try allocator.dupe(u8, stones.items[stoneIdx][0 .. stones.items[stoneIdx].len / 2]);
                const right = try allocator.dupe(u8, stones.items[stoneIdx][stones.items[stoneIdx].len / 2 ..]);
                stones.items[stoneIdx] = left;
                const parsedRight = std.fmt.parseInt(u64, right, 10) catch 1;
                if (parsedRight == 0) {
                    var tmp: [1]u8 = undefined;
                    try stones.insert(stoneIdx + 1, try std.fmt.bufPrint(&tmp, "{s}", .{&[_]u8{'0'}}));
                } else {
                    var idx: u64 = 0;
                    for (right, 0..) |char, idxx| {
                        if (char == '0') {
                            continue;
                        }
                        idx = idxx;
                        break;
                    }
                    const komnuu = try allocator.dupe(u8, right[idx..]);
                    try stones.insert(stoneIdx + 1, komnuu);
                }
                stoneIdx += 1;
            } else {
                const value = try std.fmt.parseInt(u64, stones.items[stoneIdx], 10);
                var buf: [100]u8 = undefined;
                const newValue = try std.fmt.bufPrint(&buf, "{}", .{value * 2024});
                const newStone = try allocator.alloc(u8, newValue.len);
                stones.items[stoneIdx] = newStone;
                std.mem.copyForwards(u8, stones.items[stoneIdx], newValue);
            }
            stoneIdx += 1;
        }
    }
    return stones.items.len;
}

const mapType = std.StringHashMap(u64);
fn p2() !u64 {
    print("----- Part2 -----\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var stones = std.ArrayList([]u8).init(allocator);
    defer stones.deinit();
    var stonesIter = std.mem.tokenizeAny(u8, input, " \n");

    while (stonesIter.next()) |stone| {
        const buf = try allocator.alloc(u8, stone.len);
        std.mem.copyForwards(u8, buf, stone);
        try stones.append(buf);
    }

    var map = mapType.init(allocator);
    var result: u64 = 0;
    for (stones.items) |stone| {
        const tmp = try solveStone(stone, 75, &map, allocator);
        result += tmp;
    }
    map.deinit();
    return result;
}

fn solveStone(stone: []const u8, blinks: comptime_int, map: *mapType, allocator: @TypeOf(std.heap.page_allocator)) !u64 {
    if (blinks == 0) {
        return 1;
    }

    const keyBuf = try allocator.alloc(u8, 20);
    const key = try std.fmt.bufPrint(keyBuf, "{}:{s}", .{ blinks, stone });
    if (map.*.get(key)) |result| {
        return result;
    }

    var result: u64 = 0;
    if (rule1(stone)) {
        result = try solveStone(&[1]u8{'1'}, blinks - 1, map, allocator);
    } else if (rule2(stone)) {
        const left = try allocator.dupe(u8, stone[0 .. stone.len / 2]);
        result = try solveStone(left, blinks - 1, map, allocator);
        allocator.free(left);

        const right = try allocator.dupe(u8, stone[stone.len / 2 ..]);
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
            const komnuu = try allocator.dupe(u8, right[idx..]);
            defer allocator.free(komnuu);
            result += try solveStone(komnuu, blinks - 1, map, allocator);
        }
        allocator.free(right);
    } else {
        const value = try std.fmt.parseInt(u64, stone, 10);
        // var buf: [30]u8 = undefined;
        const newValue = try std.fmt.allocPrint(allocator, "{}", .{value * 2024});
        result = try solveStone(newValue, blinks - 1, map, allocator);
    }

    // print("Putting now: {s} --- result: {}\n", .{ stone, result });
    try map.*.put(key, result);
    return result;
}

fn rule1(stone: []const u8) bool {
    const value = std.fmt.parseInt(u8, stone, 10) catch return false;
    return value == 0;
}

fn rule2(stone: []const u8) bool {
    return stone.len % 2 == 0;
}
