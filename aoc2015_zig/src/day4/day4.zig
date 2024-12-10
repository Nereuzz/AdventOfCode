const std = @import("std");
const input = @embedFile("test.txt");
const print = std.debug.print;
const Md5 = std.crypto.hash.Md5;

pub fn main() !void {
    print("Day 3:\n", .{});
    try p1();
}

fn p1() !void {
    var lines = std.mem.splitAny(u8, input, "\n");
    const base = lines.first();
    var p1Solved = false;
    const fives = [_]u8{'0'} ** 5;
    const sixes = [_]u8{'0'} ** 6;

    for (1..std.math.maxInt(u64)) |i| {
        var buf: [Md5.digest_length]u8 = undefined;
        const concatted = try std.fmt.bufPrint(&buf, "{s}{}", .{ base, i });
        Md5.hash(concatted, &buf, .{});

        const hashString = std.fmt.bytesToHex(buf, std.fmt.Case.lower)[0..6];
        if (!p1Solved) {
            if (std.mem.eql(u8, hashString[0..5], &fives)) {
                p1Solved = true;
                print("Part1: {}\n", .{i});
            }
        }
        if (std.mem.eql(u8, hashString, &sixes)) {
            print("Part2: {}\n", .{i});
            return;
        }
    }

    return;
}

fn p2() !void {
    return try p1();
}
