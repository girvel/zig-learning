const std = @import("std");
const rl = @import("raylib");

pub const Voxel = struct {
    position: rl.Vector3,
    color: rl.Color,
};

pub fn load_voxels(path: []const u8, allocator: std.mem.Allocator) anyerror!std.ArrayList(Voxel) {
    var result = std.ArrayList(Voxel).init(allocator);

    var file = try std.fs.cwd().openFile(path, .{});
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

        try result.append(Voxel{
            .position = rl.Vector3.init(x, z, y),
            .color = rl.getColor((try std.fmt.parseInt(u32, color_hex, 16) << 8) + 0xff),
        });
    }

    return result;
}

