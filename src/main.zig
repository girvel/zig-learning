const std = @import("std");
const rl = @import("raylib");
const expect = std.testing.expect;

pub fn main() anyerror!void {
    var first_line: []u8 = undefined;
    {
        var file = try std.fs.cwd().openFile("demo.txt", .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1024]u8 = undefined;
        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            first_line = line;
            break;
        }
    }

    std.debug.print("{s}\n", .{first_line});

    const w = 800;
    const h = 600;

    rl.initWindow(w, h, "Game of Life");
    defer rl.closeWindow();

    var camera = rl.Camera {
        .position = rl.Vector3.init(4, 4, 4),
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

        rl.beginMode3D(camera);
        defer rl.endMode3D();

        rl.clearBackground(rl.Color.white);

        rl.drawGrid(10, 1.0);
        rl.drawCube(rl.Vector3.one().scale(0.5), 1, 1, 1, rl.Color.black);
        rl.drawFPS(10, 10);
    }
}
