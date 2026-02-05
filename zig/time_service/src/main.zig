const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    _ = allocator; // autofix

    const address = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, 5000);
    var server = try address.listen(.{ .reuse_address = true });
    std.debug.print("Server is running at {s}:{d}\n", .{ "127.0.0.1", address.getPort() });
    defer server.deinit();

    while (true) {
        var connection = try server.accept();
        defer connection.stream.close();

        var recv_buffer: [4000]u8 = undefined;
        var send_buffer: [4000]u8 = undefined;

        var conn_reader = connection.stream.reader(&recv_buffer);
        var conn_writer = connection.stream.writer(&send_buffer);

        var http_server = std.http.Server.init(conn_reader.interface(), &conn_writer.interface);
        var request = http_server.receiveHead() catch |err| {
            std.debug.print("Could not read head: {any}\n", .{err});
            continue;
        };

        try request.respond("Hello, World!!\nFrom zig backend...\n", .{});
    }
}
