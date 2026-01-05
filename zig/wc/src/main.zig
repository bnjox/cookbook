const std = @import("std");
const flags = @import("flags");

pub fn main() !void {
    var buffer: [1024]u8 = undefined;
    var stdin = std.fs.File.stdin().reader(&buffer);
    const reader = &stdin.interface;

    _ = try flags.parse();
    const count_lines = flags.boolean("l", false, "count lines");
    const count_bytes = flags.boolean("b", false, "count bytes");

    const sum = count(reader, count_lines, count_bytes);
    std.debug.print("sum: {d}\n", .{sum});
}

fn count(reader: *std.Io.Reader, count_lines: bool, count_bytes: bool) i32 {
    const contents = reader.allocRemaining(std.heap.page_allocator, .unlimited) catch return 0;

    var it: std.mem.TokenIterator(u8, .any) = undefined;
    var wc: i32 = 0;

    if (count_lines) {
        it = std.mem.tokenizeAny(u8, contents, "\n");
    } else if (count_bytes) {
        for (contents) |_| {
            wc += 1;
        }
        return wc;
    } else {
        it = std.mem.tokenizeAny(u8, contents, " \n\t\r");
    }

    while (it.next()) |_| {
        wc += 1;
    }

    return wc;
}

test "test count words" {
    var reader = std.Io.Reader.fixed("word1 word2 word3 word4");

    const s = count(&reader, false, false);
    try std.testing.expectEqual(4, s);
}

test "test count lines" {
    var reader = std.Io.Reader.fixed("word1 word2 word3\nline2\nline3 word1");

    const s = count(&reader, true, false);
    try std.testing.expectEqual(3, s);
}

test "test count bytes" {
    var reader = std.Io.Reader.fixed("word1\nword2");

    const s = count(&reader, false, true);
    try std.testing.expectEqual(11, s);
}
