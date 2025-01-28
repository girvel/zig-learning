const std = @import("std");
const raylib = @import("raylib");
const expect = std.testing.expect;

fn mod_add(x: usize, offset: i32, limit: usize) usize {
    return @intCast(@mod(@as(i32, @intCast(x)) + offset, @as(i32, @intCast(limit))));
}

fn ProduceGol(comptime w: usize, comptime h: usize) type {
    return struct {
        const Self = @This();

        field: [w * h]i32,

        fn display(self: Self) void {
            for (self.field, 0..) |value, i| {
                std.debug.print("{s}", .{if (value == 1) "X" else "."});
                if (i % w == (w - 1)) {
                    std.debug.print("\n", .{});
                }
            }
        }

        fn at(self: *Self, x: usize, y: usize) *i32 {
            return &self.field[x + y * w];
        }

        fn get_at(self: Self, x: usize, y: usize) i32 {
            return self.field[x + y * w];
        }

        fn next(self: Self) Self {
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

        fn get_width() usize { return w; }  // TODO const
        fn get_height() usize { return h; }
    };
}

pub fn main() void {
    const w = 128;
    const h = 128;

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
        break :blk seed;
    });
    const rand = prng.random();

    const Gol = ProduceGol(w, h);
    var gol = Gol{ .field = undefined };

    for (0..Gol.get_width()) |x| {
        for (0..Gol.get_height()) |y| {
            gol.at(x, y).* = if (rand.boolean()) 1 else 0;
        }
    }

    raylib.initWindow(w, h, "Game of Life");
    defer raylib.closeWindow();

    raylib.setTargetFPS(100);

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.white);

        for (0..Gol.get_width()) |x| {
            for (0..Gol.get_height()) |y| {
                raylib.drawPixel(@as(i32, @intCast(x)), @as(i32, @intCast(y)), 
                    if (gol.get_at(x, y) == 1) raylib.Color.black
                    else raylib.Color.white
                );
            }
        }

        gol = gol.next();
    }
}
