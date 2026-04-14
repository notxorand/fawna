//! Query DSL example - parse and match queries

const std = @import("std");
const fawna = @import("fawna");

pub fn main() !void {
    // Parse a query
    const query = try fawna.Query.init("AVG:temperature:[room=1]:[1000,5000]");

    std.debug.print("Series: {s}\n", .{query.series});
    std.debug.print("Tags: {d}\n", .{query.tags_len});
    std.debug.print("Has range: {}\n", .{query.has_time_range});

    // Test tag matching
    const tags = [_][]const u8{ "room=1", "floor=2" };
    const matches = query.matchesTags(tags[0..]);
    std.debug.print("Matches: {}\n", .{matches});
}
