const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const width = 600;
const height = 600;

const rows = 100;
const cols = 100;

const cell_width = width / rows;

const Cost = union(enum) {
    value: u32,
    infinity,
    wall,
};

const Point2D = struct {
    x: u32 = 0,
    y: u32 = 0,
};

const Node = struct {
    point: Point2D = .{},
    visited: bool = false,
    cost: Cost = .infinity,
    edges: [4]?*Node = undefined,
};

const Graph = struct {
    nodes: [rows * cols]Node = undefined,

    fn init(self: *Graph) void {
        // self.nodes = [_]Node{} ** (rows * cols);
        for (&self.nodes) |*e| {
            e.* = Node{};
        }

        var x: u32 = 0;
        var y: u32 = 0;

        for (&self.nodes, 0..) |*e, i| {
            x = @intCast(i % cols);
            // std.debug.print("x: {}\n", .{x});
            if (i != 0 and x == 0) y += 1;

            e.*.point.x = x;
            e.*.point.y = y;

            e.*.edges = .{
                // left
                if (x == 0) null else switch (self.nodes[i - 1].cost) {
                    .wall => null,
                    else => &self.nodes[i - 1],
                },
                //right
                if (x == cols - 1) null else switch (self.nodes[i + 1].cost) {
                    .wall => null,
                    else => &self.nodes[i + 1],
                },
                //up
                if (y == 0) null else switch (self.nodes[i - rows].cost) {
                    .wall => null,
                    else => &self.nodes[i - rows],
                },
                //down
                if (y == rows - 1) null else switch (self.nodes[i + rows].cost) {
                    .wall => null,
                    else => &self.nodes[i + rows],
                },
            };

            //test
            // if (x == 0) e.*.cost = .wall;
            // if (x == cols - 1) e.*.visited = true;
        }
    }

    fn draw(self: *Graph) void {
        for (self.nodes) |node| {
            rl.DrawRectangle(@intCast(node.point.x * cell_width), @intCast(node.point.y * cell_width), cell_width, cell_width, switch (node.cost) {
                .wall => rl.GRAY,
                else => if (node.visited) rl.GREEN else rl.WHITE,
            });
        }
    }
};

fn bfs() void {}
fn dfs() void {}
fn djikstra() void {}
fn aStar() void {}

fn randomNeighbor(current: **Node, rand: std.Random) void {
    current.*.visited = true;

    var i: u8 = rand.intRangeLessThan(u8, 0, current.*.edges.len);
    while (true) {
        if (current.*.edges[i]) |value| {
            current.* = value;
            return;
        }

        i = rand.intRangeLessThan(u8, 0, current.*.edges.len);
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

pub fn main() !void {
    var prng: std.Random.DefaultPrng = .init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    var graph = Graph{};
    graph.init();

    var current: *Node = &graph.nodes[0];
    current.cost = Cost{ .value = 0 };

    const target: Point2D = .{ .x = 2, .y = 2 };

    rl.InitWindow(width, height, "yo");
    rl.SetTargetFPS(60);
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.WHITE);

        if ((current.point.x == target.x and current.point.y == target.y)) {
            rl.DrawText("Found Goal!", @intCast(width / 2), @intCast(height / 2), 14, rl.RED);
        } else {
            randomNeighbor(&current, rand);
        }

        graph.draw();
        rl.DrawRectangle(@intCast(current.point.x * cell_width), @intCast(current.point.y * cell_width), cell_width, cell_width, rl.BLACK);

        rl.EndDrawing();
    }

    rl.CloseWindow();
}
