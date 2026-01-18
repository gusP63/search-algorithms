const std = @import("std");
const rl = @import("c.zig").rl;
const math = @import("math.zig");
const Maze = @import("Maze.zig").Maze;

pub const width = 800;
pub const height = 800;

const State = enum { menu, running };
const SubView = enum { maze, stations, boxes, gradient };

pub const App = struct {
    is_running: bool = false,
    state: State = .menu,
    subview: ?SubView = null,

    pub fn init(self: *App) !void {
        _ = self;
        try math.initRand();
        rl.InitWindow(width, height, "yo");
    }

    pub fn deinit(self: *App) void {
        _ = self;
        rl.CloseWindow();
    }

    pub fn run(self: *App) void {
        self.is_running = true;
        while (self.is_running) {
            self.input();
            self.frame();
            self.draw();
        }
    }

    fn input(self: *App) void {
        if (self.state == .running) return;

        if (rl.WindowShouldClose()) self.is_running = false;
        //TODO: a bunch of buttons, and button.isPressed callback?
        if (rl.IsKeyReleased(rl.KEY_M)) {
            self.subview = .maze;
            self.state = .running;
        }
    }

    // not really a frame but whatever
    fn frame(self: *App) void {
        if (self.state != .running) return;

        // hand control to subview
        if (self.subview) |v| {
            switch (v) {
                .maze => {
                    var maze: Maze = .create(100, 100);
                    maze.run() catch {
                        std.debug.print("Error loading maze", .{});
                    };
                    maze.destroy();
                },
                else => {},
            }
        }

        // once subview finishes, go back to the menu
        self.state = .menu;
    }

    fn draw(self: *App) void {
        if (self.state == .running) return;
        rl.BeginDrawing();

        rl.ClearBackground(rl.WHITE);
        rl.DrawText("M - Maze, T - Trains, B - Boxes", @intCast(width / 2), @intCast(height / 2), 14, rl.BLACK);
        //TODO: Draw buttons
        // select (Maze, Boxes, Trains, ...)
        // about, settings, quit

        rl.EndDrawing();
    }
};
