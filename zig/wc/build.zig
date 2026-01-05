const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "wc",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const flags = b.dependency("flags", .{});
    exe.root_module.addImport("flags", flags.module("flags"));

    b.installArtifact(exe);

    // This creates a top level step when running `zig build` (e.g. `zig build run`).
    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run the tests");

    const test_cmd = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.resolveTargetQuery(.{}),
        }),
    });

    const run_tests = b.addRunArtifact(test_cmd);
    test_step.dependOn(&run_tests.step);

    // This allows the user to pass arguments to the application like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
