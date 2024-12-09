const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
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

const File = struct { id: u64, len: u64, start: u64 };
const Block = struct { start: u64 };

fn p2() !u64 {
    var diskArray = try parseInput();
    const diskSlice: []u64 = diskArray.slice();
    var blockPointer: u64 = 0;
    var filePointer: u64 = @intCast(diskArray.slice().len - 1);
    while (true) {
        // print("Disk at start: {any}\n", .{diskSlice});
        const file = GetNextFile(filePointer, diskSlice);
        if (file.id == 0) {
            break;
        }
        // print("File to try: {}\n", .{file});
        const block = GetBlockForFile(file, diskSlice);
        // print("Block found: {any}\n", .{block});
        if (block != null and block.?.start < file.start) {
            filePointer = file.start;
            blockPointer = block.?.start;
            while (filePointer < file.start + file.len) {
                diskSlice[blockPointer] = diskSlice[filePointer];
                diskSlice[filePointer] = emptyBlock;
                filePointer += 1;
                blockPointer += 1;
            }
            filePointer = file.start - 1;
        } else {
            if (file.id == 0) {
                break;
            } else {
                filePointer = file.start - 1;
                continue;
            }
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

fn GetBlockForFile(file: File, disk: []u64) ?Block {
    var diskIter = std.mem.window(u64, disk, file.len, 1);
    var idx: u64 = 0;
    while (diskIter.next()) |window| {
        if (std.mem.allEqual(u64, window, emptyBlock)) {
            return .{ .start = idx };
        } else idx += 1;
    }
    return null;
}

fn GetNextFile(filePointer: u64, disk: []u64) File {
    var fp = filePointer;
    while (disk[fp] == emptyBlock) : (fp -= 1) {
        continue;
    }
    const id = disk[fp];
    const startIdx = fp;
    // print("fp: {}\n", .{fp});
    while (disk[fp] == id) {
        if (fp == 1) {
            return .{ .id = 0, .len = 0, .start = 0 };
        }
        fp -= 1;
    }

    return .{ .id = disk[fp + 1], .len = startIdx - fp, .start = fp + 1 };
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
