const std = @import("std");
const input = @embedFile("test.txt");
const print = std.debug.print;

pub fn main() !void {
    const sol1 = try p1();
    print("Part 1: {}\n", .{sol1});
    const sol2 = try p2();
    print("Part 2: {}\n", .{sol2});
}

fn p1() !u64 {
    const allocator = std.heap.page_allocator;
    var map = std.AutoHashMap(u8, [100]u8).init(allocator);
    defer map.deinit();

    var iter = std.mem.tokenizeSequence(u8, input, "\n\n");
    var rules = std.mem.tokenizeAny(u8, iter.next().?, "\n");
    var updates = std.mem.tokenizeAny(u8, iter.next().?, "\n");

    while (rules.next()) |rule| {
        var numbers = std.mem.tokenizeAny(u8, rule, "|");

        const key = try std.fmt.parseInt(u8, numbers.next().?, 10);
        var currentList = map.get(key);
        if (currentList) |_| {} else {
            currentList = [_]u8{0} ** 100;
        }
        const nextIdx = std.mem.indexOfScalar(u8, &currentList.?, 0).?;
        const value = try std.fmt.parseInt(u8, numbers.next().?, 10);
        currentList.?[nextIdx] = value;

        try map.put(key, currentList.?);
    }

    var result: u64 = 0;
    while (updates.next()) |update| {
        const correct = try checkUpdate(update, false, map);
        if (correct) |keys| {
            const midIdx = keys.len / 2 - 1;
            const val = try std.fmt.parseInt(u64, keys[midIdx .. midIdx + 2], 10);
            result += val;
        }
    }
    map.clearAndFree();
    return result;
}

fn p2() !u64 {
    const allocator = std.heap.page_allocator;
    var map = std.AutoHashMap(u8, [100]u8).init(allocator);
    defer map.deinit();

    var iter = std.mem.tokenizeSequence(u8, input, "\n\n");
    var rules = std.mem.tokenizeAny(u8, iter.next().?, "\n");
    var updates = std.mem.tokenizeAny(u8, iter.next().?, "\n");

    while (rules.next()) |rule| {
        var numbers = std.mem.tokenizeAny(u8, rule, "|");

        const key = try std.fmt.parseInt(u8, numbers.next().?, 10);
        var currentList = map.get(key);
        if (currentList) |_| {} else {
            currentList = [_]u8{0} ** 100;
        }
        const nextIdx = std.mem.indexOfScalar(u8, &currentList.?, 0).?;
        const value = try std.fmt.parseInt(u8, numbers.next().?, 10);
        currentList.?[nextIdx] = value;

        try map.put(key, currentList.?);
    }

    var result: u64 = 0;
    while (updates.next()) |update| {
        const correct = try checkUpdate(update, true, map);
        if (correct) |keys| {
            const fixed = try fixUpdate(update, map);
            const midIdx = fixed.len / 2 - 1;
            const val = try std.fmt.parseInt(u64, keys[midIdx .. midIdx + 2], 10);
            result += val;
        }
    }

    map.clearAndFree();
    return result;
}

fn fixUpdate(update: []const u8, mappidy: std.hash_map.HashMap(u8, [100]u8, std.hash_map.AutoContext(u8), 80)) ![]const u8 {
    var updateIter = std.mem.tokenizeAny(u8, update, ",\n");

    var result = [_]u8{0} ** 100;
    result[0] = update[0];

    _ = mappidy;

    return update;
}

fn checkUpdate(update: []const u8, getIncorrect: bool, mappidy: std.hash_map.HashMap(u8, [100]u8, std.hash_map.AutoContext(u8), 80)) !?[]const u8 {
    var correct = true;
    // print("Checking update: {s}\n", .{update});
    var updateIter = std.mem.tokenizeAny(u8, update, ",\n");
    while (updateIter.next()) |hat| {
        const toFind = try std.fmt.parseInt(u8, hat, 10);
        var keys = std.mem.tokenizeAny(u8, updateIter.rest(), ",\n");

        while (keys.next()) |key| {
            const toCheck = try std.fmt.parseInt(u8, key, 10);
            const list = mappidy.get(toCheck);
            if (list) |l| {
                for (l) |page| {
                    if (page == 0) {
                        break;
                    }
                    if (page == toFind) {
                        correct = false;
                        break;
                    }
                }
            }
        }
        if (!correct) {
            break;
        }
        if (!correct) {
            break;
        }
    }

    if (!correct and getIncorrect) {
        updateIter.reset();
        const keys = std.mem.tokenizeAny(u8, updateIter.rest(), ",\n");
        return keys.rest();
    }
    if (correct and !getIncorrect) {
        updateIter.reset();
        const keys = std.mem.tokenizeAny(u8, updateIter.rest(), ",\n");
        return keys.rest();
    } else {
        return null;
    }
}
