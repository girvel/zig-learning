const std = @import("std");
const rl = @import("raylib");
const expect = std.testing.expect;

pub fn main() void {
    const w = 800;
    const h = 600;

    rl.initWindow(w, h, "Game of Life");
    defer rl.closeWindow();

    rl.setTargetFPS(100);

    const camera = rl.Camera {
        .position = rl.Vector3.init(4, 4, 4),
        .target = rl.Vector3.zero(),
        .up = rl.Vector3.init(0, 1, 0),
        .fovy = 45,
        .projection = rl.CameraProjection.perspective,
    };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode3D(camera);
        defer rl.endMode3D();

        rl.clearBackground(rl.Color.white);

        rl.drawGrid(10, 1.0);
        rl.drawCube(rl.Vector3.zero(), 1, 1, 1, rl.Color.black);
        rl.drawFPS(10, 10);
    }
}
