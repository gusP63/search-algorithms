const std = @import("std");
const rl = @import("c.zig").rl;
const math = @import("math.zig");
const ui = @import("ui.zig");
const Maze = @import("Maze.zig").Maze;
const Boxes = @import("Boxes.zig").Boxes;

pub const width = 800;
pub const height = 800;

const State = enum {
    menu,
    running,
};
const SubMenu = enum {
    main,
    select,
    settings,
};
const SubView = enum {
    maze,
    stations,
    boxes,
    gradient,
};

pub const App = struct {
    is_running: bool = false,
    state: State = .menu,
    submenu: SubMenu = .main,
    subview: ?SubView = null,

    button_select: ui.Button = ui.Button.create(0, 64, "select", .{ .background_color = rl.RED, .margin_top = 32 }),
    button_settings: ui.Button = ui.Button.create(0, 64, "settings", .{ .background_color = rl.BLUE, .margin_top = 32 }),
    button_quit: ui.Button = ui.Button.create(0, 64, "quit", .{ .background_color = rl.GREEN, .margin_top = 32 }),

    select_maze: ui.Button = ui.Button.create(0, 64, "Maze", .{ .background_color = rl.GREEN, .margin_top = 32 }),
    select_trains: ui.Button = ui.Button.create(0, 64, "Train Stations", .{ .background_color = rl.BLUE, .margin_top = 32 }),
    select_boxes: ui.Button = ui.Button.create(0, 64, "Box Sort", .{ .background_color = rl.GRAY, .margin_top = 32 }),
    select_gradient: ui.Button = ui.Button.create(0, 64, "Color Sort", .{ .background_color = rl.RED, .margin_top = 32 }),

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

        if (rl.IsKeyReleased(rl.KEY_ESCAPE) or rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_RIGHT)) {
            if (self.submenu == .main) self.is_running = false else self.submenu = .main;
        }

        if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT)) {
            const mouse_pos: math.Point2D = .{ .x = @intCast(rl.GetMouseX()), .y = @intCast(rl.GetMouseY()) };

            switch (self.submenu) {
                .main => self.mainMenuInputs(mouse_pos),
                .select => self.selectMenuInputs(mouse_pos),
                .settings => self.settingsMenuInputs(mouse_pos),
            }
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
                .boxes => {
                    var boxes: Boxes = .{};
                    boxes.init();
                    boxes.run();
                    boxes.destroy();
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

        switch (self.submenu) {
            .main => self.mainMenuDraw(),
            .select => self.selectMenuDraw(),
            .settings => self.settingsMenuDraw(),
        }

        rl.EndDrawing();
    }

    // if button == selected, button.style.borderColor = something else

    fn mainMenuDraw(self: *App) void {
        var main_menu_options: ui.DrawAreaList = .{
            .rect = .{
                .width = 600,
                .height = 300,
                .x = 100,
                .y = 250,
            },
            .orientation = .vertical,
        };
        main_menu_options.draw(&self.button_select);
        main_menu_options.draw(&self.button_settings);
        main_menu_options.draw(&self.button_quit);
    }

    fn mainMenuInputs(self: *App, mouse_pos: math.Point2D) void {
        if (self.button_select.isMouseInside(mouse_pos)) self.submenu = .select;
        if (self.button_settings.isMouseInside(mouse_pos)) self.submenu = .settings;
        if (self.button_quit.isMouseInside(mouse_pos)) self.is_running = false;
    }

    fn selectMenuDraw(self: *App) void {
        var select_menu_options: ui.DrawAreaGrid = .{
            .rect = .{
                .width = width,
                .height = height,
                .x = 0,
                .y = 0,
            },
            .rows = 2,
            .cols = 2,
        };

        select_menu_options.draw(&self.select_maze);
        select_menu_options.draw(&self.select_trains);
        select_menu_options.draw(&self.select_boxes);
        select_menu_options.draw(&self.select_gradient);
    }

    fn selectMenuInputs(self: *App, mouse_pos: math.Point2D) void {
        if (self.select_boxes.isMouseInside(mouse_pos)) self.subview = .boxes;
        if (self.select_maze.isMouseInside(mouse_pos)) self.subview = .maze;
        if (self.select_gradient.isMouseInside(mouse_pos)) self.subview = .gradient;
        if (self.select_trains.isMouseInside(mouse_pos)) self.subview = .stations;
        self.state = .running;
    }

    fn settingsMenuDraw(self: *App) void {
        _ = self;
        rl.DrawText(
            "Settings",
            width / 2,
            height / 2,
            16,
            rl.BLACK,
        );
    }

    fn settingsMenuInputs(self: *App, mouse_pos: math.Point2D) void {
        if (self.button_select.isMouseInside(mouse_pos)) self.submenu = .select;
        if (self.button_settings.isMouseInside(mouse_pos)) self.submenu = .settings;
        if (self.button_quit.isMouseInside(mouse_pos)) self.is_running = false;
    }
};
