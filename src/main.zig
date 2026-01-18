const std = @import("std");
const App = @import("App.zig").App;

pub fn main() !void {
    var app: App = .{};
    try app.init();
    defer app.deinit();

    app.run();
}
