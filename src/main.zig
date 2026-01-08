const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const width = 800;
const height = 800;

const rows = 100;
const cols = 100;

const cell_width = width / rows;

const Cost = union(enum) {
    value: u32,
    infinity,
};

const Point2D = struct {
    x: u32 = 0,
    y: u32 = 0,
};

const Node = struct {
    point: Point2D = .{},
    visited: bool = false,
    to_be_expanded: bool = false,
    cost: Cost = .infinity,
    edges: [8]?*Node = undefined,
    parent: ?*Node = null,
    is_wall: bool = false,
};

const Graph = struct {
    nodes: [rows * cols]Node = undefined,

    fn init(self: *Graph) void {
        var y: u32 = 0;
        var x: u32 = 0;

        for (&self.nodes, 0..) |*e, i| {
            e.* = Node{};
            x = @intCast(i % cols);
            y = if (i != 0 and x == 0) y + 1 else y;

            e.point.x = x;
            e.point.y = y;
        }
    }

    fn updateEdges(self: *Graph) void {
        for (&self.nodes, 0..) |*e, i| {
            if (e.is_wall) {
                e.edges = [_]?*Node{null} ** e.edges.len;
                continue;
            }
            var tmp: Node = Node{ .is_wall = true };

            const x = e.point.x;
            const y = e.point.y;
            const northwest: *Node = if (x == 0 or y == 0) &tmp else &self.nodes[i - rows - 1];
            const west: *Node = if (x == 0) &tmp else &self.nodes[i - 1];
            const southwest: *Node = if (x == 0 or y == rows - 1) &tmp else &self.nodes[i + rows - 1];
            const south: *Node = if (y == rows - 1) &tmp else &self.nodes[i + rows];
            const southeast: *Node = if (x == cols - 1 or y == rows - 1) &tmp else &self.nodes[i + rows + 1];
            const east: *Node = if (x == cols - 1) &tmp else &self.nodes[i + 1];
            const northeast: *Node = if (x == cols - 1 or y == 0) &tmp else &self.nodes[i - rows + 1];
            const north: *Node = if (y == 0) &tmp else &self.nodes[i - 1];

            e.edges = .{
                if (northwest.is_wall) null else northwest,
                if (west.is_wall) null else west,
                if (southwest.is_wall) null else southwest,
                if (south.is_wall) null else south,
                if (southeast.is_wall) null else southeast,
                if (east.is_wall) null else east,
                if (northeast.is_wall) null else northeast,
                if (north.is_wall) null else north,
            };
        }
    }

    fn draw(self: *Graph) void {
        for (self.nodes) |node| {
            const color = if (node.is_wall) rl.GRAY else if (node.visited) rl.GREEN else rl.WHITE;

            rl.DrawRectangle(@intCast(node.point.x * cell_width), @intCast(node.point.y * cell_width), cell_width, cell_width, color);
        }
    }

    fn len(self: Graph) usize {
        return self.nodes.len;
    }
};

fn bfs(searchData: *SearchData) !void {
    searchData.current_node = try searchData.nodes_to_expand.pop();

    const current = searchData.current_node;
    for (current.edges) |e| {
        if (e == null) continue;
        if (e.?.visited or e.?.to_be_expanded) continue;

        e.?.parent = current;
        try searchData.nodes_to_expand.insert(e.?);
        e.?.to_be_expanded = true;
    }

    current.visited = true;
}

fn dfs() void {}

fn greedySearch(searchData: *SearchData) !void {
    searchData.current_node = try searchData.nodes_to_expand.pop();

    const current = searchData.current_node;
    for (current.edges) |e| {
        if (e == null) continue;
        if (e.?.visited or e.?.to_be_expanded) continue;

        e.?.parent = current;
        try searchData.nodes_to_expand.insert(e.?);
        e.?.to_be_expanded = true;
    }
    searchData.nodes_to_expand.sort(.lowerCostFirst);

    current.visited = true;
}

fn djikstra() void {}
fn aStar() void {}

const Rand = struct {
    // static variables
    var prng: std.Random.DefaultPrng = undefined;
    var random: std.Random = undefined;

    fn init() !void {
        prng = .init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });

        random = prng.random();
    }
};

fn randomNeighbor(searchData: *SearchData) void {
    searchData.current_node.visited = true;

    var i: usize = Rand.random.intRangeLessThan(usize, 0, searchData.current_node.edges.len);
    while (true) {
        if (searchData.current_node.edges[i]) |value| {
            searchData.current_node = value;
            return;
        }

        i = (i + 1) % searchData.current_node.edges.len;
    }
}

fn closest(current: *Node) *Node {
    var next: *Node = undefined;
    current.visited = true;
    next.visited = true;
    // var initial: bool = false;
    //
    // for (&current.edges) |*e| {
    //     if (e.* == null) continue;
    //     if (!initial) {
    //         next = e;
    //         initial = true;
    //     }
    //
    //     switch (e.*.?.cost) {
    //         .infinity => current.cost,
    //         // else =>
    //     }
    //
    //     const newCost: u32 = current.cost + e.*.?.cost;
    //     if (newCost <= e.*.?.cost)
    //         e.*.?.cost = newCost;
    //
    //     if (e.*.?.cost < next.cost)
    //         next = e;
    // }
    //
    // current.visited = true;
    return next;
}

const FifoError = error{
    ExceedMaxCapacity,
    ElementDoesNotExist,
};

//TODO - use generics for type and max size
const Fifo = struct {
    nodes: [rows * cols]?*Node,
    len: usize,

    pub fn init(self: *Fifo) void {
        for (&self.nodes) |*e| {
            e.* = null;
        }

        self.len = 0;
    }

    fn insert(self: *Fifo, node: *Node) FifoError!void {
        if (self.len >= rows * cols) return FifoError.ExceedMaxCapacity;

        self.nodes[self.len] = node;
        self.len += 1;
    }

    const SortType = enum { lowerCostFirst, higherCostFirst };

    fn sort(self: *Fifo, how: SortType) void {
        const FunWrappers = struct {
            // swap if e1 lower than e2
            fn lowerLast(e1: Node, e2: Node) bool {
                switch (e1.cost) {
                    .value => |v1| switch (e2.cost) {
                        .value => |v2| return v1 < v2,
                        .infinity => return true,
                    },
                    .infinity => return false,
                }
            }

            // swap if e1 higher than e2
            fn higherLast(e1: Node, e2: Node) bool {
                switch (e1.cost) {
                    .infinity => return true,
                    .value => |v1| {
                        switch (e2.cost) {
                            .infinity => return false,
                            .value => |v2| return v1 > v2,
                        }
                    },
                }
            }
        };
        switch (how) {
            .lowerCostFirst => bubbleSort(self, FunWrappers.higherLast),
            .higherCostFirst => bubbleSort(self, FunWrappers.lowerLast),
        }
    }

    fn bubbleSort(self: *Fifo, shouldSwap: *const fn (e1: Node, e2: Node) bool) void {
        var did_swap: bool = false;

        while (true) {
            did_swap = false;

            var i: usize = 0;
            while (i < self.len - 1) : (i += 1) {
                if (shouldSwap(self.nodes[i].?.*, self.nodes[i + 1].?.*)) {
                    const tmp: *Node = self.nodes[i].?;
                    self.nodes[i] = self.nodes[i + 1];
                    self.nodes[i + 1] = tmp;

                    did_swap = true;
                }
            }

            if (!did_swap) break;
        }
    }

    fn pop(self: *Fifo) FifoError!*Node {
        if (self.nodes[0] == null) return FifoError.ElementDoesNotExist;
        const head: *Node = self.nodes[0].?;

        var i: usize = 0;
        while (i < self.len - 1) : (i += 1) {
            self.nodes[i] = self.nodes[i + 1];
        }
        self.nodes[i] = null;
        self.len -= 1;

        return head;
    }
};

const GenericError = error{PointDoesNotExist};

const SearchData = struct {
    current_node: *Node = undefined,
    graph: Graph = .{},
    nodes_to_expand: Fifo = undefined,
    goal: Point2D = undefined,
    // solution: []

    fn init(self: *SearchData) void {
        self.graph.init();
        self.nodes_to_expand.init();
    }

    fn setStart(self: *SearchData, point: Point2D) GenericError!void {
        if (point.x >= cols or point.x >= rows) return GenericError.PointDoesNotExist;

        self.current_node = &self.graph.nodes[point.x + point.y * cols];
        self.nodes_to_expand.insert(self.current_node) catch unreachable;
    }

    // update individual graph costs according to distance from goal
    // lower cost means less distance to the goal
    fn measureCosts(self: *SearchData) void {
        for (&self.graph.nodes) |*e| {
            var dX: i33 = @intCast(e.point.x);
            dX -= @intCast(self.goal.x);
            dX = @intCast(@abs(dX));
            var dY: i33 = @intCast(e.point.y);
            dY -= @intCast(self.goal.y);
            dY = @intCast(@abs(dY));

            e.cost = Cost{ .value = @intCast(dX + dY) };
        }
    }

    fn reachedGoal(self: *SearchData) bool {
        return self.current_node.point.x == self.goal.x and self.current_node.point.y == self.goal.y;
    }
};

const AppState = enum { setup, running, done };

const AppData = struct {
    state: AppState = .setup,
    texture_cheese: rl.Texture2D = undefined,
    texture_rat: rl.Texture2D = undefined,

    fn init(self: *AppData) !void {
        try Rand.init();
        rl.InitWindow(width, height, "yo");
        rl.SetTargetFPS(60);

        const image_rat: rl.Image = rl.LoadImage("mouse_right.png");
        const image_cheese: rl.Image = rl.LoadImage("cheese.png");
        defer rl.UnloadImage(image_rat);
        defer rl.UnloadImage(image_cheese);

        self.texture_cheese = rl.LoadTextureFromImage(image_cheese);
        self.texture_rat = rl.LoadTextureFromImage(image_rat);
    }

    fn deinit(self: *AppData) void {
        rl.UnloadTexture(self.texture_rat);
        rl.UnloadTexture(self.texture_cheese);
    }
};

pub fn main() !void {
    var appData: AppData = .{};
    try appData.init();
    defer appData.deinit();

    var searchData: SearchData = .{};
    searchData.init();

    try searchData.setStart(.{ .x = 0, .y = 0 });
    searchData.goal = .{ .x = 50, .y = 50 };
    searchData.measureCosts();

    while (!rl.WindowShouldClose()) {
        // drawing
        rl.BeginDrawing();
        rl.ClearBackground(rl.WHITE);

        switch (appData.state) {
            .setup => {
                if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) {
                    const x = @divFloor(rl.GetMouseX(), cell_width);
                    const y = @divFloor(rl.GetMouseY(), cell_width);
                    const index: usize = @intCast(x + y * rows);
                    if (index < 0 or index >= rows * cols) return GenericError.PointDoesNotExist;

                    searchData.graph.nodes[index].is_wall = true;
                }

                if (rl.IsKeyReleased(rl.KEY_SPACE)) {
                    searchData.graph.updateEdges();
                    appData.state = .running;
                }
            },
            .running => blk: {
                if (searchData.reachedGoal()) {
                    appData.state = .done;
                    break :blk;
                }

                // randomNeighbor(&searchData);
                // try bfs(&searchData);
                try greedySearch(&searchData);
            },
            .done => {
                rl.DrawText("Found Goal!", @intCast(width / 2), @intCast(height / 2), 14, rl.RED);
                //show solution
            },
        }

        searchData.graph.draw();
        rl.DrawTexture(appData.texture_cheese, @intCast(searchData.goal.x * cell_width), @intCast(searchData.goal.y * cell_width), rl.YELLOW);
        rl.DrawTexture(appData.texture_rat, @intCast(searchData.current_node.point.x * cell_width), @intCast(searchData.current_node.point.y * cell_width), rl.BROWN);

        rl.EndDrawing();
    }

    rl.CloseWindow();
}
