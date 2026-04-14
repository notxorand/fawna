# fawna 🌼

Blazing fast, lightweight time series database engine library in Zig.

## Getting started

See [examples](./examples) to get started using fawna.

## Benchmarks

```
Optimisation: ReleaseFast. i5-10210U. SAMSUNG MZVLB256HAHQ-000H1:

millions.zig
...
ingested 1000000 (1M) points in 0.17s
write latency per item: 166ns
write speed: 6024096 WPS
peak mem: 73 MiB

--- Storage ---
  Total: 9126796 bytes (8.70 MB)
  Bytes per point: 9.13

--- Query Benchmark ---
  Querying h-9 range 900000-999999 (100K points)
  avg: 49.9344
  Run 1: 5.57ms
  Run 2: 6.32ms
  Run 3: 5.17ms
  Run 4: 5.18ms
  Run 5: 5.83ms

--- Cleanup ---
  Deleted 2 files

Done!

billions.zig
...
ingested 1000000000 (1B) points in 270.83s
write latency per item: 270ns
write speed: 3703703 WPS
peak mem: 451 MiB

--- Storage ---
  Total: 9125492185 bytes (8.50 GB)
  Bytes per point: 9.13

--- Query Benchmark ---
  Querying h-9 range 999000000-999999999 (1M points)
  avg: 50.0086
  Run 1: 89.87ms
  Run 2: 84.17ms
  Run 3: 90.59ms
  Run 4: 83.72ms
  Run 5: 85.18ms

--- Cleanup ---
  Deleted 2000 files

Done!
...
```
