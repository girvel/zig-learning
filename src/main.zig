const std = @import("std");
const expect = std.testing.expect;

fn mod_add(x: usize, offset: i8, limit: usize) usize {
    return @intCast(@mod(@as(i8, @intCast(x)) + offset, @as(i8, @intCast(limit))));
}

fn ProduceGol(comptime w: usize, comptime h: usize) type {
    return struct {
        const Self = @This();

        field: [w * h]i8,

        fn display(self: Self) void {
            for (self.field, 0..) |value, i| {
                std.debug.print("{s}", .{if (value == 1) "X" else "."});
                if (i % w == (w - 1)) {
                    std.debug.print("\n", .{});
                }
            }
        }

        fn at(self: *Self, x: usize, y: usize) *i8 {
            return &self.field[x + y * w];
        }

        fn get_at(self: Self, x: usize, y: usize) i8 {
            return self.field[x + y * w];
        }

        fn produce_next(self: Self) Self {
            var result = Self{ .field = undefined };

            for (0..w) |x| {
                for (0..h) |y| {
                    const neighbours_n = (
                        self.get_at(mod_add(x, -1, w), mod_add(y, -1, h)) +
                        self.get_at(mod_add(x, -1, w), y) +
                        self.get_at(mod_add(x, -1, w), mod_add(y, 1, h)) +
                        self.get_at(x, mod_add(y, -1, h)) +
                        self.get_at(x, mod_add(y, 1, h)) +
                        self.get_at(mod_add(x, 1, w), mod_add(y, -1, h)) +
                        self.get_at(mod_add(x, 1, w), y) +
                        self.get_at(mod_add(x, 1, w), mod_add(y, 1, h))
                    );

                    result.at(x, y).* =
                        if (self.get_at(x, y) == 0)
                            if (neighbours_n == 3) 1 else 0
                        else
                            if (neighbours_n < 2) 0
                            else if (neighbours_n < 4) 1
                            else 0;
                }
            }

            return result;
        }
    };
}

pub fn main() void {
    const Gol = ProduceGol(5, 5);
    const gol = Gol{
        .field = [_]i8{
            0, 1, 0, 1, 0,
            0, 0, 1, 1, 1,
            0, 0, 1, 1, 1,
            0, 0, 1, 1, 1,
            0, 1, 0, 1, 0,
        },
    };
    gol.display();

    const next = gol.produce_next();
    next.display();
}
