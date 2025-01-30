const std = @import("std");
const rl = @import("raylib");

const IndexingError = error{OutOfBounds};

pub const Slice3 = struct {
    base: []?rl.Color,
    size: rl.Vector3,
    allocator: std.mem.Allocator,

    pub fn init(size: rl.Vector3, allocator: std.mem.Allocator) !Slice3 {
        const w: usize = @intFromFloat(size.x);
        const h: usize = @intFromFloat(size.y);
        const d: usize = @intFromFloat(size.z);
        return Slice3 {
            .base = try allocator.alloc(?rl.Color, w * h * d),
            .size = size,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Slice3) void {
        self.allocator.free(self.base);
    }

    fn index(self: Slice3, position: rl.Vector3) !usize {
        if (position.x >= self.size.x or
            position.y >= self.size.y or
            position.z >= self.size.z) return IndexingError.OutOfBounds;

        return @intFromFloat(
            position.x + 
            position.z * self.size.x + 
            position.y * self.size.x * self.size.z
        );
    }

    pub fn at_mut(self: *Slice3, position: rl.Vector3) !*?rl.Color {
        return &self.base[try self.index(position)];
    }

    pub fn at(self: Slice3, position: rl.Vector3) !?rl.Color {
        return self.base[try self.index(position)];
    }

    pub fn load(
        path: []const u8, size: rl.Vector3, allocator: std.mem.Allocator,
    ) !Slice3 {
        var result = try Slice3.init(size, allocator);
        errdefer result.deinit();

        const offset = size.scale(0.5);

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

            (try result.at_mut(rl.Vector3.init(x, y, z).add(offset))).*
                = rl.getColor((try std.fmt.parseInt(u32, color_hex, 16) << 8) + 0xff);
        }

        return result;
    }
};

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

const expect = std.testing.expect;

test "Slice3 indexing" {
    const color = rl.Color.init(1, 1, 1, 1);
    var space = Slice3 {
        .base = try std.testing.allocator.alloc(?rl.Color, 8),
        .size = rl.Vector3.init(2, 2, 2),
        .allocator = std.testing.allocator,
    };
    defer std.testing.allocator.free(space.base);
    @memset(space.base, null);

    (try space.at_mut(rl.Vector3.one())).* = color;

    try expect(rl.colorIsEqual(space.base[7].?, color));
}
