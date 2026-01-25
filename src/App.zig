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

    button_select: ui.Button = ui.Button.create(0, 64, "select", .{ .background_color = rl.RED, .margin_top = 32 }),
    button_settings: ui.Button = ui.Button.create(0, 64, "settings", .{ .background_color = rl.BLUE, .margin_top = 32 }),
    button_settings2: ui.Button = ui.Button.create(0, 64, "settings", .{ .background_color = rl.BLUE, .margin_top = 32 }),
    button_quit: ui.Button = ui.Button.create(0, 64, "quit", .{ .background_color = rl.GREEN, .margin_top = 32 }),

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
        if (rl.IsKeyReleased(rl.KEY_M)) {
            self.subview = .maze;
            self.state = .running;
        }

        if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT)) {
            const mouse_pos: math.Point2D = .{ .x = @intCast(rl.GetMouseX()), .y = @intCast(rl.GetMouseY()) };

            if (self.button_select.isMouseInside(mouse_pos)) self.menuSelect();
            if (self.button_settings.isMouseInside(mouse_pos)) self.menuSettings();
            if (self.button_quit.isMouseInside(mouse_pos)) self.menuQuit();
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

    fn menuSelect(self: *App) void {
        _ = self;
        std.debug.print("select\n", .{});
    }

    fn menuSettings(self: *App) void {
        _ = self;
        std.debug.print("settings\n", .{});
    }

    fn menuQuit(self: *App) void {
        std.debug.print("quit\n", .{});
        self.is_running = false;
    }

    fn draw(self: *App) void {
        if (self.state == .running) return;

        var main_menu_options: ui.DrawAreaList = .{
            .rect = .{
                .width = 600,
                .height = 300,
                .x = 100,
                .y = 250,
            },
            .orientation = .vertical,
        };
        // var select_menu_options: ui.DrawAreaGrid = .{
        //     .rect = .{
        //         .width = width,
        //         .height = height,
        //         .x = 0,
        //         .y = 0,
        //     },
        //     .rows = 2,
        //     .cols = 2,
        // };
        // select_menu_options.cols = 10;

        rl.BeginDrawing();
        rl.ClearBackground(rl.WHITE);

        main_menu_options.draw(&self.button_select);
        main_menu_options.draw(&self.button_settings);
        main_menu_options.draw(&self.button_quit);

        rl.EndDrawing();
    }
};
