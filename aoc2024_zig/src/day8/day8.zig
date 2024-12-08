const std = @import("std");
const print = std.debug.print;
const input = @embedFile("test.txt");

pub fn main() !void {
    print("Day 8:\n", .{});
    const sol1 = try p1();
    const sol2 = try p2();

    print("Part 1: {}\nPart2:{}\n", .{ sol1, sol2 });
}

const Antenna = struct { x: u64, y: u64 };
const Antinode = struct { x: i64, y: i64 };

fn p1() !u64 {
    var result: u64 = 0;
    const allocator = std.heap.page_allocator;
    const antennaListType = std.BoundedArray(Antenna, 10000);
    var map = std.AutoArrayHashMap(u8, antennaListType).init(allocator);
    defer map.deinit();

    var iter = std.mem.tokenizeAny(u8, input, "\n");
    var rowIdx: u64 = 0;
    var colIdxx: u64 = 0;
    while (iter.next()) |line| : (rowIdx += 1) {
        for (line, 0..) |char, colIdx| {
            if (std.ascii.isAlphanumeric(char)) {
                const antennaGroup = try map.getOrPut(char);
                if (!antennaGroup.found_existing) {
                    var antennaList = try antennaListType.init(0);
                    try antennaList.insert(0, .{ .x = rowIdx, .y = colIdx });
                    try map.put(char, antennaList);
                } else {
                    var antennaList = antennaGroup.value_ptr.*;
                    try antennaList.insert(0, .{ .x = rowIdx, .y = colIdx });
                    antennaGroup.value_ptr.* = antennaList;
                }
                colIdxx = colIdx;
            }
        }
    }
    for (map.keys()) |key| {
        if (map.get(key)) |group| {
            const antennas = group.slice();
            var curAntenna: u64 = 0;
            while (curAntenna < antennas.len) : (curAntenna += 1) {
                const antenna = antennas[curAntenna];
                // print("Checking antenna: {}\n", .{antenna});
                for (antennas[curAntenna + 1 ..]) |nextAntenna| {
                    // print("Against: {}\n", .{nextAntenna});
                    const distX = try std.math.sub(i64, @intCast(nextAntenna.x), @intCast(antenna.x));
                    const distY = try std.math.sub(i64, @intCast(nextAntenna.y), @intCast(antenna.y));
                    const possibilites = [2]Antinode{ .{ .x = try std.math.add(i64, @intCast(antenna.x), distX), .y = try std.math.add(i64, @intCast(antenna.y), distY) }, .{ .x = try std.math.add(i64, @intCast(nextAntenna.x), distX), .y = try std.math.add(i64, @intCast(nextAntenna.y), distY) } };
                    for (possibilites) |p| {
                        print("Checking possibillity: {},{}\n", .{ p.x, p.y });
                        if (p.x > 0 and p.x < rowIdx and p.y > 0 and p.y < colIdxx) {
                            print("Found\n", .{});
                            result += 1;
                        }
                    }
                }
            }
        }
    }
    return result;
}

fn p2() !u64 {
    return 0;
}
