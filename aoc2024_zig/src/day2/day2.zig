const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    const sol1 = p1(false);
    const sol2 = p2();

    std.debug.print("Part 1 --- Safe reports: {}\n", .{sol1});
    std.debug.print("Part 2 --- Safe reports: {}\n", .{sol2});
}

fn p1(withSlack: bool) u64 {
    var reports = std.mem.tokenizeAny(u8, input, "\n");
    var safeCounter: u64 = 0;
    var totalCounter: u64 = 0;
    while (reports.next()) |report| {
        totalCounter += 1;
        if (isSafe(report, withSlack)) {
            safeCounter += 1;
        }
    }
    return safeCounter;
}

fn p2() u64 {
    return p1(true);
}

fn handleSlack(counter: u64, report: []const u8) bool {
    var rep1 = [_]u8{100} ** 50;
    var rep2 = [_]u8{100} ** 50;
    var rep3 = [_]u8{100} ** 50;
    var split = std.mem.split(u8, report, " ");
    var sliceNum: u8 = 0;
    var idx: u8 = 0;
    while (split.next()) |entry| {
        sliceNum += 1;
        if (sliceNum == counter - 2) {
            continue;
        } else {
            for (entry) |val| {
                rep1[idx] = val;
                idx += 1;
            }
            rep1[idx] = 32;
            idx += 1;
        }
    }
    split.reset();
    sliceNum = 0;
    idx = 0;
    while (split.next()) |entry| {
        sliceNum += 1;
        if (sliceNum == counter - 1) {
            continue;
        } else {
            for (entry) |val| {
                rep2[idx] = val;
                idx += 1;
            }
            rep2[idx] = 32;
            idx += 1;
        }
    }
    split.reset();
    sliceNum = 0;
    idx = 0;
    while (split.next()) |entry| {
        sliceNum += 1;
        if (sliceNum == counter) {
            continue;
        } else {
            for (entry) |val| {
                rep3[idx] = val;
                idx += 1;
            }
            rep3[idx] = 32;
            idx += 1;
        }
    }
    return isSafe(&rep1, false) or isSafe(&rep2, false) or isSafe(&rep3, false);
}

fn isSafe(report: []const u8, withSlack: bool) bool {
    var asc = false;
    var counter: u64 = 0;
    var prevVal: i64 = -1000;
    var split = std.mem.split(u8, report, " ");
    var parsedNum: i64 = 0;
    while (split.next()) |num| {
        parsedNum = std.fmt.parseInt(i64, num, 10) catch undefined;
        if (num.len > 2) {
            return true;
        }
        if (parsedNum == 100) {
            return true;
        }
        if (prevVal == -1000) {
            prevVal = parsedNum;
            counter += 1;
            continue;
        }

        const hest = @abs(parsedNum - prevVal);
        if (hest > 3 or hest < 1) {
            if (withSlack) {
                counter += 1;
                return handleSlack(counter, report);
            } else {
                return false;
            }
        }
        if (counter == 1) {
            if (parsedNum > prevVal) {
                asc = true;
                counter += 1;
                prevVal = parsedNum;
                continue;
            } else {
                counter += 1;
                prevVal = parsedNum;
                continue;
            }
        }
        if (parsedNum == prevVal) {
            if (withSlack) {
                counter += 1;
                return handleSlack(counter, report);
            } else {
                return false;
            }
        }

        if (parsedNum > prevVal) {
            if (asc) {
                prevVal = parsedNum;
                counter += 1;
                continue;
            } else {
                if (withSlack) {
                    counter += 1;
                    return handleSlack(counter, report);
                } else {
                    return false;
                }
            }
        } else if (parsedNum < prevVal) {
            if (asc) {
                if (withSlack) {
                    counter += 1;
                    return handleSlack(counter, report);
                } else {
                    return false;
                }
            } else {
                prevVal = parsedNum;
                counter += 1;
                continue;
            }
        }
    }
    return true;
}
