const std = @import("std");
const rl = @import("raylib");
const expect = std.testing.expect;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var lines = std.ArrayList([]u8).init(allocator);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    {
        var file = try std.fs.cwd().openFile("demo.txt", .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1024]u8 = undefined;
        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            if (std.mem.startsWith(u8, line, "#")) continue;
            try lines.append(try allocator.dupe(u8, line));
        }
    }

    var i: i32 = 0;
    for (lines.items) |line| {
        if (i == 20) break;
        std.debug.print("{s}\n", .{line});
        i += 1;
    }

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
