const std = @import("std");
const raylib = @import("raylib");
const expect = std.testing.expect;

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
