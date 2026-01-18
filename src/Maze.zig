const print = @import("std").debug.print;
const app = @import("App.zig");
const rl = @import("c.zig").rl;
const search = @import("search.zig");
const graph = @import("graph.zig");
const Point2D = @import("math.zig").Point2D;
const Node = graph.Node;

// const rows = 100;
// const cols = 100;
// const cell_width = app.width / app.rows;

const MazeError = error{PointDoesNotExist};

const State = enum { setup, running, done };

pub const Maze = struct {
    rows: u32,
    cols: u32,
    cell_width: u16,

    texture_cheese: rl.Texture2D,
    texture_rat: rl.Texture2D,

    is_running: bool = false,
    state: State = .setup,
    search_data: search.SearchData = .{},
    selected_start_pos: Point2D = .{ .x = 0, .y = 0 },

    pub fn create(maze_rows: u32, maze_cols: u16) Maze {
        const image_rat: rl.Image = rl.LoadImage("src/assets/mouse_right.png");
        defer rl.UnloadImage(image_rat);
        const image_cheese: rl.Image = rl.LoadImage("src/assets/cheese.png");
        defer rl.UnloadImage(image_cheese);

        if (maze_rows > app.width) @panic("Bad constraints");
        return .{
            .texture_cheese = rl.LoadTextureFromImage(image_cheese),
            .texture_rat = rl.LoadTextureFromImage(image_rat),
            .rows = maze_rows,
            .cols = maze_cols,
            .cell_width = @intCast(app.width / maze_rows),
            .is_running = false,
            .state = .setup,
        };
    }

    pub fn destroy(self: *Maze) void {
        rl.UnloadTexture(self.texture_rat);
        rl.UnloadTexture(self.texture_cheese);
    }

    pub fn run(self: *Maze) !void {
        self.search_data.init();
        try self.search_data.setStart(self.selected_start_pos);
        self.search_data.goal = .{ .x = 90, .y = 90 };
        self.search_data.measureCosts();

        self.is_running = true;
        while (self.is_running) {
            self.input();
            self.frame();
            self.draw();
        }
    }

    fn input(self: *Maze) void {
        if (rl.WindowShouldClose()) self.is_running = false;

        const cell_width = self.cell_width;
        switch (self.state) {
            .setup => {
                const x = @divFloor(rl.GetMouseX(), @as(c_int, cell_width));
                const y = @divFloor(rl.GetMouseY(), @as(c_int, cell_width));
                const mousePos: Point2D = .{ .x = @intCast(x), .y = @intCast(y) };

                if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) and self.positionIsValid(mousePos)) {
                    const index: usize = self.getArrayIndex(mousePos);
                    self.search_data.graph.nodes[index].is_wall = true;
                }

                if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT) and self.positionIsValid(mousePos)) {
                    self.selected_start_pos = mousePos;
                    self.search_data.setStart(self.selected_start_pos) catch {
                        print("index out of bounds", .{});
                        self.is_running = false;
                    };
                }

                if (rl.IsKeyReleased(rl.KEY_SPACE) or rl.IsKeyReleased(rl.KEY_ENTER)) {
                    self.search_data.graph.updateEdges();
                    self.state = .running;
                }

                if (rl.IsKeyReleased(rl.KEY_BACKSPACE))
                    self.search_data.reset(false);
            },
            .running => {
                if (rl.IsKeyReleased(rl.KEY_SPACE) or rl.IsKeyReleased(rl.KEY_ENTER)) {
                    self.search_data.reset(true);
                    self.search_data.setStart(self.selected_start_pos) catch {
                        print("index out of bounds", .{});
                        self.is_running = false;
                    };
                    self.state = .setup;
                }
            },
            .done => {
                if (rl.IsKeyReleased(rl.KEY_SPACE) or rl.IsKeyReleased(rl.KEY_ENTER)) {
                    self.search_data.reset(true);
                    self.search_data.setStart(self.selected_start_pos) catch {
                        print("index out of bounds", .{});
                        self.is_running = false;
                    };
                    self.state = .setup;
                }
            },
        }
    }

    fn frame(self: *Maze) void {
        if (self.state != .running) return;

        search.djikstra(&self.search_data) catch {
            self.search_data.found_a_solution = false;
            self.state = .done;
        };

        if (self.search_data.reachedGoal()) {
            self.search_data.found_a_solution = true;
            self.state = .done;
        }
    }

    fn draw(self: *Maze) void {
        const cell_width = self.cell_width;

        rl.BeginDrawing();

        rl.ClearBackground(rl.WHITE);

        self.search_data.graph.draw(cell_width);
        rl.DrawTexture(self.texture_cheese, @intCast(self.search_data.goal.x * cell_width), @intCast(self.search_data.goal.y * cell_width), rl.YELLOW);
        rl.DrawTexture(self.texture_rat, @intCast(self.search_data.current_node.point.x * cell_width), @intCast(self.search_data.current_node.point.y * cell_width), rl.BROWN);
        if (self.state == .done) {
            if (self.search_data.found_a_solution) {
                var iterator: *Node = self.search_data.current_node;
                while (iterator.parent != null) {
                    rl.DrawRectangle(@intCast(iterator.point.x * cell_width), @intCast(iterator.point.y * cell_width), cell_width, cell_width, rl.DARKGREEN);
                    iterator = iterator.parent.?;
                }

                rl.DrawText("Found Solution!", @intCast(14), @intCast(14), 24, rl.RED);
            } else {
                rl.DrawText("Could not find a solution... :(", @intCast(14), @intCast(14), 24, rl.RED);
            }
        }

        rl.EndDrawing();
    }

    fn positionIsValid(self: Maze, point: Point2D) bool {
        const x = point.x;
        const y = point.y;
        return x >= 0 and y >= 0 and (x + y * self.rows) < self.rows * self.cols;
    }

    fn getArrayIndex(self: Maze, from: Point2D) usize {
        return @intCast(from.x + from.y * self.rows);
    }
};
