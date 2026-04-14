//! Fawna: Blazing fast, lightweight time series database engine library in Zig.
//!
//! This library provides efficient time series storage and querying capabilities
//! with the following components:
//!
//! - **TSM Tree**: Time Series Management tree with compression and caching
//! - **Query Engine**: Tag-based query parser and matcher for filtering data
//!
//! # Usage
//!
//! ```zig
//! const fawna = @import("fawna");
//! const tsm = fawna.tsm;
//! const query = fawna.query;
//!
//! var tree = try tsm.TsmTree.init(allocator, "my_tsm");
//! defer tree.deinit();
//!
//! // Insert data points
//! try tree.insert("series_key", .{ .timestamp = 1000, .value = .{ .Float = 42.5 } });
//!
//! // Query data
//! const results = try tree.query("series_key", 0, 2000, .SUM);
//! ```

pub const tsm = @import("tsm/tsm.zig");
pub const query = @import("query.zig");
pub const query_executor = @import("query_executor.zig");

// Re-export commonly used types for convenience
pub const TsmTree = tsm.TsmTree;
pub const Query = query.Query;
pub const QueryOp = query.QueryOp;
pub const SeriesAndTags = query.SeriesAndTags;
pub const TimestampEncoding = tsm.TimestampEncoding;
pub const ExecuteContext = query_executor.ExecuteContext;
pub const executeQuery = query_executor.executeQuery;

test {
    _ = tsm;
    _ = query;
}
