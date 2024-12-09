const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");
const Array = @import("/Users/peter/Code/ZigArrayLib/src/root.zig");
const emptyBlock = std.math.maxInt(u64);

pub fn main() !void {
    const sol1 = try p1();
    const sol2 = try p2();

    print("Day9:\nPart1: {}\nPart2: {}\n", .{ sol1, sol2 });
}

fn p1() !u64 {
    var diskArray = try parseInput();
    var diskSlice: []u64 = diskArray.slice();
    var blockPointer: u64 = 0;
    while (diskSlice[blockPointer] != emptyBlock) : (blockPointer += 1) {
        continue;
    }
    var filePointer: u64 = @intCast(diskArray.slice().len - 1);
    // print("Sanity: {any}\n", .{diskSlice[filePointer - 5 .. filePointer + 1]});
    while (blockPointer < filePointer) {
        diskSlice[blockPointer] = diskSlice[filePointer];
        diskSlice[filePointer] = emptyBlock;

        while (diskSlice[filePointer] == emptyBlock) : (filePointer -= 1) {
            continue;
        }

        while (diskSlice[blockPointer] != emptyBlock) : (blockPointer += 1) {
            continue;
        }
    }

    var result: u64 = 0;
    var sumIdx: u64 = 0;
    while (sumIdx < diskSlice.len) : (sumIdx += 1) {
        if (diskSlice[sumIdx] != emptyBlock) {
            result += diskSlice[sumIdx] * sumIdx;
        }
    }

    return result;
}

fn p2() !u64 {
    const diskArray = try parseInput();
    _ = diskArray;
    return 0;
}

fn parseInput() !std.BoundedArray(u64, 100000) {
    var diskIter = std.mem.window(u8, input, 1, 1);

    var fileId: u64 = 0;
    var diskArray = try std.BoundedArray(u64, 100000).init(0);
    var diskIdx: u64 = 0;
    var file: bool = true;
    while (diskIter.next()) |number| {
        if (number[0] == 10) {
            continue;
        }
        var blockLength = try std.fmt.parseInt(u64, number, 10);
        if (file) {
            while (blockLength > 0) : (blockLength -= 1) {
                try diskArray.insert(diskIdx, fileId);
                diskIdx += 1;
            }
            file = false;
            fileId += 1;
        } else {
            while (blockLength > 0) : (blockLength -= 1) {
                try diskArray.insert(diskIdx, emptyBlock);
                diskIdx += 1;
            }
            file = true;
        }
    }

    return diskArray;
}
