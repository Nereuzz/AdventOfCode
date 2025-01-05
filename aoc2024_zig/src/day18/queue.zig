const std = @import("std");
const print = std.debug.print;
const Order = std.math.Order;

const Point = struct {
    row: u8,
    col: u8,
    dist: u64,

    fn compare(_: void, a: Point, b: Point) Order {
        return std.math.order(a.dist, b.dist);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const p1: Point = .{ .row = 0, .col = 0, .dist = 10 };
    const p2: Point = .{ .row = 0, .col = 0, .dist = 15 };
    const p3: Point = .{ .row = 0, .col = 0, .dist = 8 };

    var q = std.PriorityQueue(Point, void, Point.compare).init(allocator, {});
    defer q.deinit();

    try q.add(p2);
    try q.add(p3);
    try q.add(p1);

    const next = q.remove();
    print("{}\n", .{next});
}
