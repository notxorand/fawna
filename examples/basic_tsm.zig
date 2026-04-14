//! Basic TSM example - insert and query data

const std = @import("std");
const fawna = @import("fawna");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tree = try fawna.TsmTree.init(allocator, "example");
    defer tree.deinit();

    // Insert some data points
    try tree.insert("temperature", .{ .timestamp = 1000, .value = .{ .Float = 20.5 } });
    try tree.insert("temperature", .{ .timestamp = 2000, .value = .{ .Float = 21.0 } });
    try tree.insert("temperature", .{ .timestamp = 3000, .value = .{ .Float = 20.8 } });

    // Query with aggregations
    const sum = try tree.query("temperature", 0, 4000, .SUM);
    const avg = try tree.query("temperature", 0, 4000, .AVG);
    const max = try tree.query("temperature", 0, 4000, .MAX);

    std.debug.print("SUM: {d}\n", .{sum.Float});
    std.debug.print("AVG: {d}\n", .{avg.Float});
    std.debug.print("MAX: {d}\n", .{max.Float});
}
