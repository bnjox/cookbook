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
    var buffer: [100]u8 = undefined;
    var stdin = std.fs.File.stdin();
    var reader = stdin.reader(&buffer);

    std.debug.print("Name of output file: ", .{});
    const output_file = try reader.interface.takeDelimiterExclusive('\n');

    const output_filepath = try std.mem.concat(allocator, u8, &.{
        current_dir,
        "/data/",
        if (output_file.len == 0) "output.txt" else output_file,
    });
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
