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
    const w = 800;
    const h = 600;

    raylib.initWindow(w, h, "Game of Life");
    defer raylib.closeWindow();

    raylib.setTargetFPS(100);

    const camera = raylib.Camera {
        .position = raylib.Vector3{.x = 4, .y = 4, .z = 4},  // TODO test anonymous
        .target = raylib.Vector3{.x = 0, .y = 0, .z = 0},
        .up = raylib.Vector3{.x = 0, .y = 1, .z = 0},
        .fovy = 45,
        .projection = raylib.CameraProjection.perspective,
    };

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.beginMode3D(camera);
        defer raylib.endMode3D();

        raylib.clearBackground(raylib.Color.white);

        raylib.drawGrid(10, 1.0);
        raylib.drawCube(raylib.Vector3 {.x = 0, .y = 0, .z = 0}, 1, 1, 1, raylib.Color.black);
        raylib.drawFPS(10, 10);
    }
}
