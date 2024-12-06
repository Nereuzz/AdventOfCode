const std = @import("std");
const input = @embedFile("input.txt");
const print = std.debug.print;

pub fn main() !void {
    print("Day 5: ---- Ouch Den er sløv den her..\n", .{});
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
    var map2 = std.AutoHashMap(u8, [100]u8).init(allocator);
    defer map.deinit();
    defer map2.deinit();

    var iter = std.mem.tokenizeSequence(u8, input, "\n\n");
    var rules = std.mem.tokenizeAny(u8, iter.next().?, "\n");
    var updates = std.mem.tokenizeAny(u8, iter.next().?, "\n");

    while (rules.next()) |rule| {
        var numbers = std.mem.tokenizeAny(u8, rule, "|");

        const key = try std.fmt.parseInt(u8, numbers.next().?, 10);
        const value = try std.fmt.parseInt(u8, numbers.next().?, 10);
        var currentList = map.get(key);
        if (currentList) |_| {} else {
            currentList = [_]u8{0} ** 100;
        }
        const nextIdx = std.mem.indexOfScalar(u8, &currentList.?, 0).?;
        currentList.?[nextIdx] = value;

        try map.put(key, currentList.?);
    }
    rules.reset();
    while (rules.next()) |rule| {
        var numbers = std.mem.tokenizeAny(u8, rule, "|");

        const value = try std.fmt.parseInt(u8, numbers.next().?, 10);
        const key = try std.fmt.parseInt(u8, numbers.next().?, 10);
        var currentList = map2.get(key);
        if (currentList) |_| {} else {
            currentList = [_]u8{0} ** 100;
        }
        const nextIdx = std.mem.indexOfScalar(u8, &currentList.?, 0).?;
        currentList.?[nextIdx] = value;

        try map2.put(key, currentList.?);
    }

    var result: u64 = 0;
    while (updates.next()) |update| {
        const correct = try checkUpdate(update, true, map);

        if (correct) |keys| {
            var keysIter = std.mem.tokenizeAny(u8, keys, ",");
            var intKeys = try std.BoundedArray(u8, 100).init(keysIter.rest().len);
            var idx: u64 = 0;
            while (keysIter.next()) |page| {
                const parsed = try std.fmt.parseInt(u8, page, 10);
                try intKeys.insert(idx, parsed);
                idx += 1;
            }
            const val = try fixUpdate(intKeys.slice()[0..idx], false, map2);
            result += val;
        }
    }

    map.clearAndFree();
    return result;
}

fn fixUpdate(pages: []const u8, reordered: bool, mappidy: std.hash_map.HashMap(u8, [100]u8, std.hash_map.AutoContext(u8), 80)) !u64 {
    const allocator = std.heap.page_allocator;
    var disallowed_after = std.AutoHashMap(u8, u8).init(allocator);
    defer disallowed_after.deinit();

    for (pages, 0..) |page, i| {
        if (disallowed_after.contains(page)) {
            const j = disallowed_after.get(page).?;
            var newPages = try std.BoundedArray(u8, 100).init(pages.len);
            try newPages.insertSlice(0, pages[0..j]);
            try newPages.insert(j, page);
            try newPages.insertSlice(j + 1, pages[j..i]);
            try newPages.insertSlice(i, pages[i + 1 ..]);
            disallowed_after.clearAndFree();
            return fixUpdate(newPages.slice()[0..pages.len], true, mappidy);
        }

        if (mappidy.contains(page)) {
            const hest: [100]u8 = mappidy.get(page).?;
            for (hest) |p| {
                if (p == 0) {
                    break;
                }
                if (!disallowed_after.contains(p)) {
                    try disallowed_after.put(p, @intCast(i));
                }
            }
        }
    }

    disallowed_after.clearAndFree();
    return if (reordered) pages[pages.len / 2] else 0;
}

fn checkUpdate(update: []const u8, getIncorrect: bool, mappidy: std.hash_map.HashMap(u8, [100]u8, std.hash_map.AutoContext(u8), 80)) !?[]const u8 {
    var correct = true;
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
