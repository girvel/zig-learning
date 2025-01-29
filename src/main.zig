const std = @import("std");
const rl = @import("raylib");
const expect = std.testing.expect;

const Voxel = struct {
    position: rl.Vector3,
    color: rl.Color,
};

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var voxels = std.ArrayList(Voxel).init(allocator);
    defer voxels.deinit();

    {
        var file = try std.fs.cwd().openFile("demo.txt", .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1024]u8 = undefined;
        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            if (std.mem.startsWith(u8, line, "#")) continue;
            
            var iter = std.mem.split(u8, line, " ");
            const x = @as(f32, @floatFromInt(try std.fmt.parseInt(i32, iter.next().?, 10)));
            const y = @as(f32, @floatFromInt(try std.fmt.parseInt(i32, iter.next().?, 10)));
            const z = @as(f32, @floatFromInt(try std.fmt.parseInt(i32, iter.next().?, 10)));
            var color_hex = iter.next().?;
            if (std.mem.endsWith(u8, color_hex, "\r")) color_hex = color_hex[0..color_hex.len - 1];

            try voxels.append(Voxel{
                .position = rl.Vector3.init(x, z, y),
                .color = rl.getColor((try std.fmt.parseInt(u32, color_hex, 16) << 8) + 0xff),
            });
        }
    }

    const w = 800;
    const h = 600;

    rl.initWindow(w, h, "Game of Life");
    defer rl.closeWindow();

    var camera = rl.Camera {
        .position = rl.Vector3.one().scale(12),
        .target = rl.Vector3.zero(),
        .up = rl.Vector3.init(0, 1, 0),
        .fovy = 45,
        .projection = rl.CameraProjection.perspective,
    };

    rl.disableCursor();
    rl.setTargetFPS(100);

    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.free);

        rl.beginDrawing();
        defer rl.endDrawing();

        {
            rl.beginMode3D(camera);
            defer rl.endMode3D();

            rl.clearBackground(rl.Color.white);

            rl.drawGrid(100, 1.0);
            for (voxels.items) |voxel| {
                rl.drawCube(rl.Vector3.one().scale(0.5).add(voxel.position), 1, 1, 1, voxel.color);
            }
        }

        rl.drawFPS(10, 10);
    }
}
