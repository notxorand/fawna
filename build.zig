const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the library module
    const fawna_mod = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Export the module so dependents can use it
    b.modules.put("fawna", fawna_mod) catch @panic("OOM");

    // Build the library
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "fawna",
        .root_module = fawna_mod,
    });

    b.installArtifact(lib);

    // Library tests
    const lib_unit_tests = b.addTest(.{
        .root_module = fawna_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Examples
    const examples_step = b.step("examples", "Build and run all examples");

    inline for ([_][]const u8{ "basic_tsm", "query_parsing", "series_and_tags", "query_executor" }) |example_name| {
        const example_mod = b.createModule(.{
            .root_source_file = b.path("examples/" ++ example_name ++ ".zig"),
            .target = target,
            .optimize = optimize,
        });
        example_mod.addImport("fawna", fawna_mod);

        const example_exe = b.addExecutable(.{
            .name = example_name,
            .root_module = example_mod,
        });

        b.installArtifact(example_exe);

        const example_run = b.addRunArtifact(example_exe);
        const example_step = b.step("example-" ++ example_name, "Run " ++ example_name ++ " example");
        example_step.dependOn(&example_run.step);

        examples_step.dependOn(&example_run.step);
    }

    // Benchmarks
    const benchmark_optimize: std.builtin.OptimizeMode = .ReleaseFast;

    const codspeed = b.dependency("codspeed", .{
        .target = target,
        .optimize = benchmark_optimize,
    });

    const billions_mod = b.createModule(.{
        .root_source_file = b.path("billions.zig"),
        .target = target,
        .optimize = benchmark_optimize,
    });
    billions_mod.addImport("codspeed", codspeed.module("codspeed"));

    const billions_exe = b.addExecutable(.{
        .name = "billions",
        .root_module = billions_mod,
    });

    b.installArtifact(billions_exe);

    const billions_run_step = b.step("billions", "Run the billions benchmark");
    const billions_run_cmd = b.addRunArtifact(billions_exe);
    billions_run_step.dependOn(&billions_run_cmd.step);

    const millions_mod = b.createModule(.{
        .root_source_file = b.path("millions.zig"),
        .target = target,
        .optimize = benchmark_optimize,
    });
    millions_mod.addImport("codspeed", codspeed.module("codspeed"));

    const millions_exe = b.addExecutable(.{
        .name = "millions",
        .root_module = millions_mod,
    });

    b.installArtifact(millions_exe);

    const millions_run_step = b.step("millions", "Run the millions benchmark");
    const millions_run_cmd = b.addRunArtifact(millions_exe);
    millions_run_step.dependOn(&millions_run_cmd.step);
}
