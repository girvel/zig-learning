const std = @import("std");
const expect = std.testing.expect;

pub fn main() void {
    const game_field = [_]bool{
        false, true,  false, true, false,
        false, false, true,  true, true,
        false, false, true,  true, true,
        false, false, true,  true, true,
        false, true,  false, true, false,
    };
    const game_field_width = 5;

    for (game_field, 0..) |value, i| {
        std.debug.print("{s}", .{if (value) "X" else "."});
        if (i % game_field_width == (game_field_width - 1)) {
            std.debug.print("\n", .{});
        }
    }
}
