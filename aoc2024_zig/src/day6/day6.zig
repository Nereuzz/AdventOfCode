const std = @import("std");
const input = @embedFile("input.txt");
const print = std.debug.print;

pub fn main() !void {
    print("Day 6:\n", .{});
    const sol1 = try p1();
    print("Part 1: {}\n", .{sol1});
    const sol2 = try p2();
    print("Part 2: {}", .{sol2});
}
const Direction = enum { Up, Right, Down, Left };

const Guard = struct { x: u64, y: u64, direction: Direction, patrolling: bool };
const Visited = struct { x: u64, y: u64, d: Direction };

fn p1() !u64 {
    var map = read_input();
    var guard: Guard = .{ .x = 0, .y = 0, .direction = Direction.Up, .patrolling = false };
    var result: u64 = 0;

    for (map, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == '^') {
                guard.patrolling = true;
                guard.x = @intCast(rowIdx);
                guard.y = @intCast(colIdx);
                map[rowIdx][colIdx] = 'X';
                result += 1;
            }
        }
    }

    const outOfBounds = false;
    while (!outOfBounds) {
        // for (map) |row| {
        //     print("{c}\n", .{row});
        // }
        const newX = switch (guard.direction) {
            Direction.Up => std.math.sub(u64, guard.x, 1) catch {
                return result;
            },
            Direction.Down => guard.x + 1,
            else => guard.x,
        };
        const newY = switch (guard.direction) {
            Direction.Left => std.math.sub(u64, guard.y, 1) catch {
                return result;
            },
            Direction.Right => guard.y + 1,
            else => guard.y,
        };
        if (newX >= map[0..].len or newY >= map[0][0..].len) {
            return result;
        }
        const ahead = map[newX][newY];

        if (ahead == '.') {
            map[newX][newY] = 'X';
            result += 1;
            guard.x = newX;
            guard.y = newY;
        } else if (ahead == '#') {
            guard.direction = switch (guard.direction) {
                Direction.Up => Direction.Right,
                Direction.Right => Direction.Down,
                Direction.Down => Direction.Left,
                Direction.Left => Direction.Up,
            };
        } else if (ahead == 'X') {
            guard.x = newX;
            guard.y = newY;
        } else {
            unreachable;
        }
    }
    return result;
}

fn p2() !u64 {
    var map = read_input();
    var guard: Guard = .{ .x = 0, .y = 0, .direction = Direction.Up, .patrolling = false };
    var result: u64 = 0;
    var startR: u64 = 0;
    var startC: u64 = 0;

    for (map, 0..) |row, rowIdx| {
        for (row, 0..) |col, colIdx| {
            if (col == '^') {
                guard.patrolling = true;
                guard.x = rowIdx;
                guard.y = colIdx;
                startR = rowIdx;
                startC = colIdx;
            }
        }
    }

    for (map, 0..) |row, rowIdx| {
        for (row, 0..) |_, colIdx| {
            if (rowIdx == startR and colIdx == startC) {
                continue;
            }
            guard.x = startR;
            guard.y = startC;
            guard.direction = Direction.Up;
            var seen = try std.BoundedArray(Visited, 10000).init(0);
            var loop = false;
            while (true) {
                // print("Ahh {}\n", .{seen.slice().len});
                for (seen.slice()) |visited| {
                    if (std.meta.eql(visited, .{ .x = guard.x, .y = guard.y, .d = guard.direction })) {
                        result += 1;
                        loop = true;
                        break;
                    }
                }
                if (loop) {
                    break;
                }
                try seen.append(.{ .x = guard.x, .y = guard.y, .d = guard.direction });

                const newX = switch (guard.direction) {
                    Direction.Up => std.math.sub(u64, guard.x, 1) catch {
                        break;
                    },
                    Direction.Down => guard.x + 1,
                    else => guard.x,
                };
                const newY = switch (guard.direction) {
                    Direction.Left => std.math.sub(u64, guard.y, 1) catch {
                        break;
                    },
                    Direction.Right => guard.y + 1,
                    else => guard.y,
                };
                if (newX >= map[0..].len or newY >= map[0][0..].len) {
                    break;
                }
                const ahead = map[newX][newY];
                if (ahead == '#' or newX == rowIdx and newY == colIdx) {
                    guard.direction = switch (guard.direction) {
                        Direction.Up => Direction.Right,
                        Direction.Right => Direction.Down,
                        Direction.Down => Direction.Left,
                        Direction.Left => Direction.Up,
                    };
                } else {
                    guard.x = newX;
                    guard.y = newY;
                }
            }
        }
    }
    return result;
}

fn read_input() [130][130]u8 {
    var linesIter = std.mem.tokenizeAny(u8, input, "\n");
    var map: [130][130]u8 = undefined;
    var rowIdx: u64 = 0;
    while (linesIter.next()) |row| {
        var colIdx: u64 = 0;
        for (row) |char| {
            map[rowIdx][colIdx] = char;
            colIdx += 1;
        }
        rowIdx += 1;
    }
    return map;
}
