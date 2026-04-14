//! Series and tags parsing example - for event processing

const std = @import("std");
const fawna = @import("fawna");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Parse event tags from CSV format
    const csv = "series=temperature,location=office,floor=2";
    const parsed = try fawna.Query.parseSeriesAndTags(allocator, csv);
    defer allocator.free(parsed.tags);

    std.debug.print("Series: {s}\n", .{parsed.series});
    std.debug.print("Tags:\n", .{});
    for (parsed.tags) |tag| {
        std.debug.print("  {s}\n", .{tag});
    }

    // Test matching against a query
    const query = try fawna.Query.init("AVG:temperature:[location=office]:");
    const matches = query.matchesTags(parsed.tags);
    std.debug.print("Matches query: {}\n", .{matches});
}
