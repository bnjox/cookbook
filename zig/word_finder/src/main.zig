const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const current_dir = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(current_dir);

    const input_filepath = try std.mem.concat(allocator, u8, &.{ current_dir, "/data/input.txt" });
    defer allocator.free(input_filepath);
    const contents = try read_file(allocator, input_filepath);
    defer allocator.free(contents);

    const amount = std.mem.replacementSize(u8, contents, "utilize", "use");
    const replaced = try allocator.alloc(u8, amount);
    defer allocator.free(replaced);

    const count = std.mem.replace(u8, contents, "utilize", "use", replaced);

    const output_filepath = try std.mem.concat(allocator, u8, &.{ current_dir, "/data/output.txt" });
    defer allocator.free(output_filepath);
    try write_to_file(output_filepath, replaced);

    std.debug.print("replaced word {d} times\n", .{count});
}

fn read_file(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });
    const contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer file.close();

    return contents;
}

fn write_to_file(file_path: []const u8, contents: []const u8) !void {
    const file = try std.fs.cwd().createFile(file_path, .{ .read = false, .truncate = false });
    defer file.close();
    _ = try file.write(contents);
}
