const std = @import("std");

const Product = struct {
    name: []const u8,
    price: f16,
    quantity: u8,
};

pub fn main() !void {
    var product_buffer: [100]u8 = undefined;
    var stdin = std.fs.File.stdin();

    var file_buffer: [1024]u8 = undefined;
    const contents = try std.fs.cwd().readFile("./src/products.json", &file_buffer);

    const parsed = try std.json.parseFromSlice(struct { products: []Product }, std.heap.smp_allocator, contents, .{});
    const products: []Product = parsed.value.products;

    outer: while (true) {
        std.debug.print("What is the product name? ", .{});
        var reader = stdin.reader(&product_buffer);
        const product_name = try reader.interface.takeDelimiterExclusive('\n');

        for (products) |product| {
            if (std.ascii.eqlIgnoreCase(product.name, product_name)) {
                std.debug.print("Name: {s}\nPrice: ${d:.2}\nQuantity on hand: {d}\n", .{ product.name, product.price, product.quantity });
                break :outer;
            }
        }

        std.debug.print("Sorry, that product was not found in our inventory.\n\n", .{});
    }
}
