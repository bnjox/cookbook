const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "time_service",
        .root_module = b.createModule(.{
            .root_source_file = b.path("./src/main.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app.");
    const run_cmd = b.addRunArtifact(exe);

    run_step.dependOn(&run_cmd.step);
}
