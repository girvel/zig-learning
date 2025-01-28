const std = @import("std");
const expect = std.testing.expect;

const FIELD_SIZE = 25;

const Gol = struct {
    field: [FIELD_SIZE]i8,
    width: usize,

    fn display(self: Gol) void {
        for (self.field, 0..) |value, i| {
            std.debug.print("{s}", .{if (value == 1) "X" else "."});
            if (i % self.width == (self.width - 1)) {
                std.debug.print("\n", .{});
            }
        }
    }

    fn get_at(self: Gol, x: i8, y: i8) i8 {
        const x_: usize = @intCast(@mod(x, @as(i8, @intCast(self.width))));
        const y_: usize = @intCast(@mod(y, @as(i8, @intCast(self.field.len / self.width))));
        return self.field[x_ + y_ * self.width];
    }

    fn set_at(self: *Gol, x: i8, y: i8, value: i8) void {  // TODO at
        const x_: usize = @intCast(@mod(x, @as(i8, @intCast(self.width))));
        const y_: usize = @intCast(@mod(y, @as(i8, @intCast(self.field.len / self.width))));
        self.field[x_ + y_ * self.width] = value;
    }

    fn produce_next(self: Gol) Gol {
        var result = Gol{ .field = undefined, .width = self.width };

        for (0..self.width) |x_usize| {
            for (0..self.field.len / self.width) |y_usize| {
                const x: i8 = @intCast(x_usize);
                const y: i8 = @intCast(y_usize);

                const neighbours_n = (
                    self.get_at(x - 1, y - 1) +
                    self.get_at(x - 1, y) +
                    self.get_at(x - 1, y + 1) +
                    self.get_at(x, y - 1) +
                    self.get_at(x, y + 1) +
                    self.get_at(x + 1, y - 1) +
                    self.get_at(x + 1, y) +
                    self.get_at(x + 1, y + 1)
                );
                result.set_at(x, y,
                    if (self.get_at(x, y) == 0)
                        if (neighbours_n == 3) 1 else 0
                    else
                        if (neighbours_n < 2) 0
                        else if (neighbours_n < 4) 1
                        else 0
                );
            }
        }
        return result;
    }
};

pub fn main() void {
    const gol = Gol{
        .field = [_]i8{
            0, 1, 0, 1, 0,
            0, 0, 1, 1, 1,
            0, 0, 1, 1, 1,
            0, 0, 1, 1, 1,
            0, 1, 0, 1, 0,
        },
        .width = 5,
    };
    gol.display();

    const next = gol.produce_next();
    next.display();
}
