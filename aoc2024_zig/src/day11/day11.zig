const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

pub fn main() !void {
    const sol1 = try p1();
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

    const blinks: u64 = 75;
    for (0..blinks) |i| {
        print("NEXT BLINK: {}\n", .{i + 1});
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
            // print("StonesAfter: {s}\n", .{stones.items});
        }
    }
    return stones.items.len;
}

fn rule1(stone: []const u8) bool {
    const value = std.fmt.parseInt(u8, stone, 10) catch return false;
    return value == 0;
}

fn rule2(stone: []const u8) bool {
    return stone.len % 2 == 0;
}

fn p2() !u64 {
    return 0;
}
