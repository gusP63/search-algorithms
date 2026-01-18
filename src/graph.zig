const app = @import("App.zig");
const rl = @import("c.zig").rl;
const Point2D = @import("math.zig").Point2D;

pub const Cost = union(enum) {
    value: u32,
    infinity,
};

pub const Node = struct {
    point: Point2D = .{},
    visited: bool = false,
    to_be_expanded: bool = false,
    cost: Cost = .infinity,
    edges: [8]?*Node = undefined,
    parent: ?*Node = null,
    is_wall: bool = false,
};

//TODO: not hardcoded
const cols = 100;
const rows = 100;

pub const Graph = struct {
    nodes: [100 * 100]Node = undefined,

    pub fn init(self: *Graph) void {
        var y: u32 = 0;
        var x: u32 = 0;

        //todo: this should be just for maze(or make this a different func, not default init)
        // I should be able to design the graph by hand
        for (&self.nodes, 0..) |*e, i| {
            e.* = Node{};
            x = @intCast(i % cols);
            y = if (i != 0 and x == 0) y + 1 else y;

            e.point.x = x;
            e.point.y = y;
        }
    }

    // same thing as above
    pub fn updateEdges(self: *Graph) void {
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
            const north: *Node = if (y == 0) &tmp else &self.nodes[i - rows];

            e.edges = .{
                if (north.is_wall) null else north,
                if (south.is_wall) null else south,
                if (west.is_wall) null else west,
                if (east.is_wall) null else east,
                if (northwest.is_wall) null else northwest,
                if (southwest.is_wall) null else southwest,
                if (southeast.is_wall) null else southeast,
                if (northeast.is_wall) null else northeast,
            };
        }
    }

    //todo: add option for drawing a circle/rectangle/triangle
    pub fn draw(self: *Graph, node_width: u16) void {
        for (self.nodes) |node| {
            const color = if (node.is_wall) rl.GRAY else if (node.visited) rl.GREEN else rl.WHITE;

            //todo: might not want to multiply by node_width
            rl.DrawRectangle(@intCast(node.point.x * node_width), @intCast(node.point.y * node_width), node_width, node_width, color);
            // rl.DrawCircle
        }
    }

    pub fn reset(self: *Graph, keep_walls: bool) void {
        for (&self.nodes) |*node| {
            node.visited = false;
            node.to_be_expanded = false;
            node.parent = null;

            if (!keep_walls)
                node.is_wall = false;
        }
    }

    pub fn len(self: Graph) usize {
        return self.nodes.len;
    }
};
