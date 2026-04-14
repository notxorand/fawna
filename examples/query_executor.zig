//! Query executor example - parse DSL and execute against tree

const std = @import("std");
const fawna = @import("fawna");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize tree
    var tree = try fawna.TsmTree.init(allocator, "example");
    defer tree.deinit();

    // Insert some data
    try tree.insert("temperature", .{ .timestamp = 1000, .value = .{ .Float = 20.5 } });
    try tree.insert("temperature", .{ .timestamp = 2000, .value = .{ .Float = 21.0 } });
    try tree.insert("temperature", .{ .timestamp = 3000, .value = .{ .Float = 22.1 } });

    // Create execution context
    var ctx = fawna.ExecuteContext{
        .tree = &tree,
        .allocator = allocator,
        .series_lookup = seriesLookup,
    };

    // Execute query DSL
    const result = try fawna.executeQuery(&ctx, "AVG:temperature:[]:[0,5000]");
    std.debug.print("Result: {d}\n", .{result.value});
    std.debug.print("Series count: {}\n", .{result.series_count});
}

fn seriesLookup(
    ctx: *fawna.ExecuteContext,
    series_name: []const u8,
    tags: []const []const u8,
) std.mem.Allocator.Error![][]const u8 {
    _ = tags;
    var keys = std.ArrayList([]const u8).init(ctx.allocator);
    try keys.append(series_name);
    return keys.items;
}
