const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

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

        const now_seconds: u64 = @intCast(std.time.timestamp());
        const epoch_secs = std.time.epoch.EpochSeconds{ .secs = now_seconds };
        const epoch_day = epoch_secs.getEpochDay();
        const day_seconds = epoch_secs.getDaySeconds();
        const year_day = epoch_day.calculateYearDay();
        const month_day = year_day.calculateMonthDay();

        const month_names = [_][]const u8{ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
        const month_name = month_names[@intFromEnum(month_day.month) - 1];

        const current_time = try std.fmt.allocPrint(allocator, "{d:0>2}:{d:0>2}:{d:0>2} UTC {s} {d} {d}", .{
            day_seconds.getHoursIntoDay(),
            day_seconds.getMinutesIntoHour(),
            day_seconds.getSecondsIntoMinute(),
            month_name,
            month_day.day_index + 1,
            year_day.year,
        });
        defer allocator.free(current_time);

        const formatter = try std.json.Stringify.valueAlloc(allocator, .{ .currentTime = current_time }, .{});
        std.debug.print("Timestamp: {s}\n", .{current_time});

        try request.respond(formatter, .{
            .extra_headers = &.{
                .{ .name = "Content-Type", .value = "application/json" },
            },
        });
    }
}
