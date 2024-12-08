const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

pub fn main() !void {
    print("Day 7:\n", .{});
    const sol1 = try p1(false);
    const sol2 = try p2();

    print("Part 1: {}\n", .{sol1});
    print("Part 2: {}\n", .{sol2});
}

const ComputeState = struct { i: u64, value: u64 };

fn p1(part2: bool) !u64 {
    var result: u64 = 0;
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var numbers = [_]u64{0} ** 100000;
        var split = std.mem.splitSequence(u8, line, ": ");
        const target = try std.fmt.parseInt(u64, split.next().?, 10);
        var numIter = std.mem.splitAny(u8, split.next().?, " ");
        var idx: u64 = 0;
        while (numIter.next()) |num| {
            numbers[idx] = try std.fmt.parseInt(u64, num, 10);
            idx += 1;
        }
        const totalNumbers = idx + 1;
        const allocator = std.heap.page_allocator;
        const queueType = std.fifo.LinearFifo(ComputeState, .Dynamic);
        var queue = queueType.init(allocator);
        try queue.writeItem(.{ .i = 1, .value = numbers[0] });
        while (queue.readItem()) |comp| {
            if (comp.i == totalNumbers) {
                if (comp.value == target) {
                    result += target;
                    break;
                }
                continue;
            }

            const nextNumber = numbers[comp.i];
            // print("Next number: {}\n", .{nextNumber});
            const added = comp.value + nextNumber;
            const mulled = comp.value * nextNumber;
            if (added <= target) {
                // print("Adding added to queue: {}\n", .{added});
                try queue.writeItem(.{ .i = comp.i + 1, .value = added });
            }
            if (mulled <= target) {
                // print("Adding mulled to queue: {}\n", .{mulled});
                try queue.writeItem(.{ .i = comp.i + 1, .value = mulled });
            }
            if (part2) {
                var leftBuf: [100]u8 = undefined;
                const leftString = try std.fmt.bufPrint(&leftBuf, "{}{}", .{ comp.value, numbers[comp.i] });
                // print("Leftstring: {s}\n", .{leftString});
                const concatted = try std.fmt.parseInt(u64, leftString, 10);
                try queue.writeItem(.{ .i = comp.i + 1, .value = concatted });
            }
        }
    }
    return result;
}

fn p2() !u64 {
    return try p1(true);
}
