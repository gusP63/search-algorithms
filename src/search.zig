const app = @import("App.zig");
const cast = @import("cast.zig").cast;
const graph = @import("graph.zig");
const math = @import("math.zig");
const Fifo = @import("containers.zig").Fifo;
const print = @import("std").debug.print;

const Graph = graph.Graph;
const Node = graph.Node;
const Cost = graph.Cost;
const Point2D = math.Point2D;
const random = math.random;

const SearchError = error{ NoSolutionFound, InsertionError, BadAccess };

const cols = 100;
const rows = cols;

// todo: this should prob be in maze
pub const SearchData = struct {
    current_node: *Node = undefined,
    graph: Graph = .{},
    nodes_to_expand: Fifo = undefined,
    goal: Point2D = undefined,
    found_a_solution: bool = false,

    pub fn init(self: *SearchData) void {
        self.graph.init();

        self.nodes_to_expand.init();
        self.current_node = &self.graph.nodes[0];
        self.nodes_to_expand.insert(self.current_node) catch @panic("error inserting node");
    }

    pub fn reset(self: *SearchData, keep_walls: bool) void {
        self.graph.reset(keep_walls);

        self.nodes_to_expand.clear();
    }

    pub fn setStart(self: *SearchData, point: Point2D) SearchError!void {
        if (point.x >= cols or point.x >= rows) return SearchError.BadAccess;
        self.current_node = &self.graph.nodes[point.x + point.y * cols];
        self.nodes_to_expand.clear();
        self.nodes_to_expand.insert(self.current_node) catch @panic("error inserting node");
    }

    // update individual graph costs according to distance from goal
    // lower cost means less distance to the goal
    pub fn measureCosts(self: *SearchData) void {
        for (&self.graph.nodes) |*e| {
            var dX: i33 = cast(i33, e.point.x) - cast(i33, self.goal.x);
            if (dX < 0) dX = -dX;
            var dY: i33 = cast(i33, e.point.y) - cast(i33, self.goal.y);
            if (dY < 0) dY = -dY;

            e.cost = Cost{ .value = @abs(dX + dY) };
        }
    }

    pub fn reachedGoal(self: *SearchData) bool {
        return self.current_node.point.x == self.goal.x and self.current_node.point.y == self.goal.y;
    }
};

// search algorithms
pub const SearchFnType = *const fn (*SearchData) SearchError!void;

pub fn djikstra(search_data: *SearchData) SearchError!void {
    search_data.current_node = search_data.nodes_to_expand.pop() catch return SearchError.NoSolutionFound;

    const current = search_data.current_node;
    for (current.edges) |e| {
        if (e == null) continue;
        if (e.?.visited or e.?.to_be_expanded) continue;

        e.?.parent = current;
        search_data.nodes_to_expand.insertSorted(e.?) catch return SearchError.InsertionError;
        e.?.to_be_expanded = true;
    }

    current.visited = true;
}

pub fn bfs(search_data: *SearchData) SearchError!void {
    search_data.current_node = search_data.nodes_to_expand.pop() catch return SearchError.NoSolutionFound;

    const current = search_data.current_node;
    for (current.edges) |e| {
        if (e == null) continue;
        if (e.?.visited or e.?.to_be_expanded) continue;

        e.?.parent = current;
        search_data.nodes_to_expand.insert(e.?) catch return SearchError.InsertionError;
        e.?.to_be_expanded = true;
    }

    current.visited = true;
}

pub fn randomNeighbor(search_data: *SearchData) SearchError!void {
    search_data.current_node.visited = true;

    var i: usize = random.intRangeLessThan(usize, 0, search_data.current_node.edges.len);
    while (true) {
        if (search_data.current_node.edges[i]) |value| {
            search_data.current_node = value;
            return;
        }

        i = (i + 1) % search_data.current_node.edges.len;
    }
}

// fn aStar() void {}
// fn greedySearch(search_data: *SearchData) SearchError!void {
//     const current = search_data.current_node;
//     var next: ?*Node = null;
//
//     for (current.edges) |e| {
//         if (e == null) continue;
//         if (e.?.visited) continue;
//
//         if (next == null)
//             next = e.?;
//         if (e.?.cost.value < next.?.cost.value)
//             next = e.?;
//     }
//     if (next == null)
//         next = current.parent;
//
//     search_data.nodes_to_expand.sort(.lowerCostFirst);
//
//     current.visited = true;
//     next.?.parent = current;
//
//     search_data.current_node = next.?;
// }
//
// fn delayedGratification(search_data: *SearchData) SearchError!void {
//     search_data.current_node = search_data.nodes_to_expand.pop() catch return SearchError.NoSolutionFound;
//
//     const current = search_data.current_node;
//     for (current.edges) |e| {
//         if (e == null) continue;
//         if (e.?.visited or e.?.to_be_expanded) continue;
//
//         e.?.parent = current;
//         search_data.nodes_to_expand.insert(e.?) catch return SearchError.InsertionError;
//         e.?.to_be_expanded = true;
//     }
//     search_data.nodes_to_expand.sort(.higherCostFirst);
//
//     current.visited = true;
// }
//
// fn dfs() void {}
