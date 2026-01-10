const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const c_warnings = &.{
        "-std=c23",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Werror",
    };

    const parson = b.addStaticLibrary(.{
        .name = "parson",
        .target = target,
        .optimize = optimize,
    });
    parson.addCSourceFiles(.{
        .files = &.{"parson.c"},
        .flags = c_warnings,
    });
    parson.linkLibC();

    b.installArtifact(parson);
    b.installHeader("parson.h", "parson.h");

    const test_flags = &.{
        "-std=c23",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Werror",
        "-DTESTS_MAIN",
    };

    const tests = b.addExecutable(.{
        .name = "parson-tests",
        .target = target,
        .optimize = optimize,
    });
    tests.addCSourceFiles(.{
        .files = &.{"tests.c", "parson.c"},
        .flags = test_flags,
    });
    tests.linkLibC();

    const run_tests = b.addRunArtifact(tests);
    run_tests.cwd = b.project_root;
    if (b.args) |args| {
        run_tests.addArgs(args);
    }

    const test_step = b.step("test", "Run parson tests");
    test_step.dependOn(&run_tests.step);

    const collision_tests = b.addExecutable(.{
        .name = "parson-tests-collisions",
        .target = target,
        .optimize = optimize,
    });
    collision_tests.addCSourceFiles(.{
        .files = &.{"tests.c", "parson.c"},
        .flags = &.{
            "-std=c23",
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-Werror",
            "-DTESTS_MAIN",
            "-DPARSON_FORCE_HASH_COLLISIONS",
        },
    });
    collision_tests.linkLibC();

    const run_collision_tests = b.addRunArtifact(collision_tests);
    run_collision_tests.cwd = b.project_root;
    if (b.args) |args| {
        run_collision_tests.addArgs(args);
    }

    const collision_step = b.step("test-collisions", "Run tests with forced hash collisions");
    collision_step.dependOn(&run_collision_tests.step);
}
