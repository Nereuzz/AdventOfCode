const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

pub fn main() !void {
    print("Day 8:\n", .{});
    const sol1 = try p1(false);
    const sol2 = try p2();

    print("Part1: {}\nPart2: {}\n", .{ sol1, sol2 });
}

const Antenna = struct { x: u64, y: u64 };
const Antinode = struct { x: i64, y: i64 };

fn p1(part2: bool) !u64 {
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
            }
            colIdxx = colIdx + 1;
        }
    }
    var resultArray = try std.BoundedArray(Antinode, 10000).init(0);
    for (map.keys()) |key| {
        if (map.get(key)) |group| {
            const antennas = group.slice();
            var curAntenna: u64 = 0;
            while (curAntenna < antennas.len) : (curAntenna += 1) {
                const antenna = antennas[curAntenna];
                // print("Checking antenna: {}\n", .{antenna});
                for (antennas) |nextAntenna| {
                    if (std.meta.eql(antenna, nextAntenna)) {
                        continue;
                    }
                    const distX = try std.math.sub(i64, @intCast(antenna.x), @intCast(nextAntenna.x));
                    const distY = try std.math.sub(i64, @intCast(antenna.y), @intCast(nextAntenna.y));
                    const possibilites = [2]Antinode{ .{ .x = try std.math.add(i64, @intCast(antenna.x), distX), .y = try std.math.add(i64, @intCast(antenna.y), distY) }, .{ .x = try std.math.sub(i64, @intCast(nextAntenna.x), distX), .y = try std.math.sub(i64, @intCast(nextAntenna.y), distY) } };
                    if (!part2) {
                        for (possibilites) |p| {
                            // print("Checking possibillity: {}\n", .{p});
                            if (p.x >= 0 and p.x < rowIdx and p.y >= 0 and p.y < colIdxx) {
                                var exists = false;
                                for (resultArray.slice()) |knownNode| {
                                    exists = knownNode.x == p.x and knownNode.y == p.y;
                                    if (exists) {
                                        // print("Skipping inserting known {}\n", .{knownNode});
                                        break;
                                    }
                                }
                                if (!exists) {
                                    // print("Adding {} to results\n", .{p});
                                    try resultArray.insert(0, p);
                                    // print("Result after add: {}\n", resultArray.slice());
                                }
                            }
                        }
                    } else {
                        var x: i64 = @intCast(antenna.x);
                        var y: i64 = @intCast(antenna.y);
                        while (x >= 0 and x < rowIdx and y >= 0 and y < colIdxx) {
                            var exists = false;
                            for (resultArray.slice()) |knownNode| {
                                exists = knownNode.x == x and knownNode.y == y;
                                if (exists) {
                                    break;
                                }
                            }
                            if (!exists) {
                                try resultArray.insert(0, .{ .x = x, .y = y });
                            }
                            x = try std.math.add(i64, x, distX);
                            y = try std.math.add(i64, y, distY);
                        }

                        x = @intCast(nextAntenna.x);
                        y = @intCast(nextAntenna.y);
                        while (x >= 0 and x < rowIdx and y >= 0 and y < colIdxx) {
                            var exists = false;
                            for (resultArray.slice()) |knownNode| {
                                exists = knownNode.x == x and knownNode.y == y;
                                if (exists) {
                                    break;
                                }
                            }
                            if (!exists) {
                                try resultArray.insert(0, .{ .x = x, .y = y });
                            }
                            x = try std.math.sub(i64, x, distX);
                            y = try std.math.sub(i64, y, distY);
                        }
                    }
                }
            }
        }
    }
    // print("Restul: {any}\n", .{resultArray.slice()});
    return resultArray.slice().len;
}

fn p2() !u64 {
    return try p1(true);
}
