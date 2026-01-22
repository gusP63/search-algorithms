const std = @import("std");
const rl = @import("c.zig").rl;
const math = @import("math.zig");
const Maze = @import("Maze.zig").Maze;
const ui = @import("ui.zig");

pub const width = 800;
pub const height = 800;

const State = enum { menu, running };
const SubView = enum { maze, stations, boxes, gradient };

pub const App = struct {
    is_running: bool = false,
    state: State = .menu,
    subview: ?SubView = null,

    button_select: ui.Button = ui.Button.create(0, 64, "select", menuSelect, .{ .background_color = rl.RED }),
    button_settings: ui.Button = ui.Button.create(0, 64, "settings", menuSelect, .{ .background_color = rl.BLUE }),
    button_quit: ui.Button = ui.Button.create(0, 64, "quit", menuSelect, .{ .background_color = rl.GREEN }),

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

    // if button == selected, button.style.borderColor = something else

    fn menuSelect() void {
        std.debug.print("select\n", .{});
    }

    fn draw(self: *App) void {
        if (self.state == .running) return;

        // what I want to do
        // const padd = 64;
        var main_menu_options: ui.DrawAreaList = ui.DrawAreaList.create(.{ .x = 64, .y = 64 }, 240, 400, .vertical);

        rl.BeginDrawing();
        rl.ClearBackground(rl.WHITE);

        main_menu_options.draw(&self.button_select);
        main_menu_options.draw(&self.button_settings);
        main_menu_options.draw(&self.button_quit);

        rl.EndDrawing();
    }
};
