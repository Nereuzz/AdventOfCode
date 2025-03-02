const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");

const Towel = []u8;
const Design = []u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    defer _ = gpa.deinit();

    var towels = try std.BoundedArray([]u8, 1000).init(0);
    var designs = try std.BoundedArray([]u8, 1000).init(0);

    defer {
        for (towels.slice()) |t| allocator.free(t);
        for (designs.slice()) |d| allocator.free(d);
    }

    var linesIter = std.mem.splitSequence(u8, input, "\n\n");
    var towelsIter = std.mem.tokenizeSequence(u8, linesIter.next().?, ", ");
    var designsIter = std.mem.tokenizeScalar(u8, linesIter.next().?, '\n');

    while (towelsIter.next()) |t| try towels.append(try allocator.dupe(u8, t));
    while (designsIter.next()) |d| try designs.append(try allocator.dupe(u8, d));

    const sol1 = try p1(towels.slice(), designs.slice());
    const sol2 = try p2();

    print("Day 19:\nPart 1: {}\nPart2: {}\n", .{ sol1, sol2 });
}

fn sortTowels(_: void, lhs: Towel, rhs: Towel) bool {
    return lhs.len > rhs.len;
}

fn p1(towels: []Towel, designs: []Design) !u64 {
    var result: u64 = 0;
    std.mem.sort(Towel, towels, {}, sortTowels);
    for (designs) |design| {
        if (MakeDesign(design, towels)) result += 1;
    }

    return result;
}

fn MakeDesign(design: Design, towels: []Towel) bool {
    var curLen: usize = 1;
    if (design.len == 0) return true;
    var target = design[0..curLen];

    while (target.len > 0) {
        for (towels) |towel| {
            if (std.mem.eql(u8, towel, target)) {
                if (MakeDesign(design[towel.len..], towels)) {
                    return true;
                }
            }
        }
        curLen += 1;
        if (curLen > design.len) break;
        target = design[0..curLen];
    }

    return false;
}

fn p2() !u64 {
    return 0;
}
