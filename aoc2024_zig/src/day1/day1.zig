const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    const lists = parse_input();
    var left = lists.left;
    var right = lists.right;
    std.mem.sort(i64, &left, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, &right, {}, comptime std.sort.asc(i64));

    const sol1: u64 = p1(&left, &right);
    const sol2: u64 = p2(&left, &right);
    std.debug.print("Part 1: {any}\n", .{sol1});
    std.debug.print("Part 2: {any}\n", .{sol2});
}

fn p1(left: []i64, right: []i64) u64 {
    var distance: u64 = 0;
    for (0..1000) |i| {
        distance += @intCast(@abs(left[i] - right[i]));
    }
    return distance;
}

fn p2(left: []i64, right: []i64) u64 {
    var similarity: u64 = 0;
    for (0..1000) |i| {
        const current_val: u64 = @intCast(left[i]);
        const first_idx = std.mem.indexOf(i64, right, &[_]i64{left[i]});
        if (first_idx == null) {
            continue;
        }
        const last_idx = std.mem.lastIndexOf(i64, right, &[_]i64{left[i]});
        similarity += current_val * ((last_idx.? + 1) - first_idx.?);
    }
    return similarity;
}

fn parse_input() struct { left: [1000]i64, right: [1000]i64 } {
    var iter = std.mem.tokenizeAny(u8, input, "\n");

    var left = [_]i64{0} ** 1000;
    var right = [_]i64{0} ** 1000;

    var idx: u64 = 0;
    var lenOfFirst: usize = 0;
    while (iter.next()) |entry| {
        lenOfFirst = std.mem.indexOfMin(u8, entry);
        left[idx] = std.fmt.parseInt(i64, entry[0..lenOfFirst], 10) catch return .{ .left = left, .right = right };
        right[idx] = std.fmt.parseInt(i64, entry[lenOfFirst + 3 ..], 10) catch return .{ .left = left, .right = right };
        idx += 1;
    }

    return .{ .left = left, .right = right };
}
