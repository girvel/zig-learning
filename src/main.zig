const std = @import("std");
const rl = @import("raylib");
const space = @import("space.zig");
const expect = std.testing.expect;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const voxels = try space.load_voxels("assets/demo.txt", allocator);

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

    const shader = try rl.loadShader(
        "assets/shaders/main_vert.glsl",
        "assets/shaders/main_frag.glsl"
    );

    rl.disableCursor();
    rl.setTargetFPS(100);

    while (!rl.windowShouldClose()) {
        rl.updateCamera(&camera, rl.CameraMode.free);

        rl.beginDrawing();
        defer rl.endDrawing();

        {
            rl.beginMode3D(camera);
            defer rl.endMode3D();

            rl.beginShaderMode(shader);
            defer rl.endShaderMode();

            rl.clearBackground(rl.Color.white);

            rl.drawGrid(100, 1.0);
            for (voxels.items) |voxel| {
                rl.drawCube(rl.Vector3.one().scale(0.5).add(voxel.position), 1, 1, 1, voxel.color);
            }
        }

        rl.drawFPS(10, 10);
    }
}

test {std.testing.refAllDecls(@This());}

