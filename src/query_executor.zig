//! Query executor - bridges DSL queries to TSM tree aggregation
//! Takes a query string like "AVG:temperature:[room=1]:[1000,5000]"
//! and aggregates results across matching series keys

const std = @import("std");
const query_mod = @import("query.zig");
const tsm_mod = @import("tsm/tsm.zig");

const Query = query_mod.Query;
const QueryOp = query_mod.QueryOp;
const TsmTree = tsm_mod.TsmTree;

/// Context for query execution
pub const ExecuteContext = struct {
    tree: *TsmTree,
    allocator: std.mem.Allocator,

    /// Callback to get all series keys matching a series name and tags
    /// Returns allocated array of series keys (caller must free)
    series_lookup: *const fn (
        ctx: *ExecuteContext,
        series_name: []const u8,
        tags: []const []const u8,
    ) std.mem.Allocator.Error![][]const u8,
};

/// Result of executing a query DSL string
pub const QueryResult = struct {
    value: f64,
    series_count: u64,
};

/// Parse DSL query string and execute against tree
/// Returns aggregated value across all matching series
pub fn executeQuery(
    ctx: *ExecuteContext,
    query_str: []const u8,
) !QueryResult {
    // Parse the query DSL
    const q = try Query.init(query_str);

    // Get matching series keys
    var tag_slice = std.ArrayList([]const u8).init(ctx.allocator);
    defer tag_slice.deinit();

    for (q.tags[0..q.tags_len]) |tag| {
        switch (tag) {
            .tag => |t| try tag_slice.append(t),
            .op => {},
        }
    }

    const series_keys = try ctx.series_lookup(ctx, q.series, tag_slice.items);
    defer ctx.allocator.free(series_keys);

    // Determine time range
    const start = if (q.has_time_range) q.time_start else std.math.minInt(i64);
    const end = if (q.has_time_range) q.time_end else std.math.maxInt(i64);

    // Aggregate across all matching series
    const result = try aggregateSeriesKeys(
        ctx,
        series_keys,
        start,
        end,
        q.op,
    );

    return QueryResult{
        .value = result.value,
        .series_count = series_keys.len,
    };
}

/// Aggregate query results across multiple series keys
fn aggregateSeriesKeys(
    ctx: *ExecuteContext,
    series_keys: []const []const u8,
    start: i64,
    end: i64,
    op: QueryOp,
) !struct { value: f64 } {
    var sum: f64 = 0;
    var min = std.math.inf(f64);
    var max = -std.math.inf(f64);
    var count: u64 = 0;

    for (series_keys) |series_key| {
        const values = ctx.tree.queryRaw(series_key, start, end) catch continue;
        defer ctx.allocator.free(values);

        for (values) |value| {
            const f = switch (value) {
                .Float => |v| v,
                .Int => |v| @as(f64, @floatFromInt(v)),
                .Bool => |v| @as(f64, @floatFromInt(@intFromBool(v))),
                .Bytes => 0,
            };

            sum += f;
            if (f < min) min = f;
            if (f > max) max = f;
            count += 1;
        }
    }

    const result = switch (op) {
        .Sum => sum,
        .Count => @as(f64, @floatFromInt(count)),
        .Min => if (count == 0) 0 else min,
        .Max => if (count == 0) 0 else max,
        .Avg => if (count == 0) 0 else sum / @as(f64, @floatFromInt(count)),
        .None => 0,
    };

    return .{ .value = result };
}
