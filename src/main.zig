const std = @import("std");
const expect = std.testing.expect;

fn display_field(game_field: []const bool, width: usize) void {
    for (game_field, 0..) |value, i| {
        std.debug.print("{s}", .{if (value) "X" else "."});
        if (i % width == (width - 1)) {
            std.debug.print("\n", .{});
        }
    }
}

pub fn main() void {
    const game_field = [_]bool{
        false, true,  false, true, false,
        false, false, true,  true, true,
        false, false, true,  true, true,
        false, false, true,  true, true,
        false, true,  false, true, false,
    };
    const game_field_width = 5;
    //const game_field_height = 5;

    display_field(&game_field, game_field_width);
}
