# Examples

Minimal examples demonstrating Fawna library usage.

## basic_tsm.zig

Insert data points and query with aggregations.

```bash
zig build example-basic_tsm
```

## query_parsing.zig

Parse query DSL and test tag matching.

```bash
zig build example-query_parsing
```

## series_and_tags.zig

Parse series and tags from CSV format.

```bash
zig build example-series_and_tags
```

## query_executor.zig

Execute DSL queries against the tree with aggregation.

This is the main pattern - parse a DSL string like `AVG:temperature:[room=1]:[1000,5000]` and execute it against the tree to get aggregated results across matching series.

```bash
zig build example-query_executor
```

## Query DSL

Format: `OP:SERIES:[TAGS]:[RANGE]`

- **OP**: AVG, SUM, MIN, MAX, COUNT
- **SERIES**: Series identifier
- **TAGS**: Boolean expressions (AND, OR, NOT)
- **RANGE**: Optional [start,end]

Example: `AVG:temperature:[room=1 AND floor=2]:[1000,5000]`

## CSV Format

`series=name,tag1=value1,tag2=value2`

- Series prefix optional (defaults to "temp")
- Whitespace auto-trimmed

## Building

```bash
zig build examples      # Build and run all
zig build test         # Run tests
```
