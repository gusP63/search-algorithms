const app = @import("App.zig");
const Node = @import("graph.zig").Node;

// Fifo
const FifoError = error{
    ExceedMaxCapacity,
    ElementDoesNotExist,
};

//TODO - use generics for type and max capacity
//Also, this is not really a fifo, since you can insert ordered, maybe just array list or smth
const capacity = 100 * 100;
pub const Fifo = struct {
    nodes: [capacity]?*Node,
    len: usize,

    pub fn init(self: *Fifo) void {
        for (&self.nodes) |*e| {
            e.* = null;
        }

        self.len = 0;
    }

    pub fn clear(self: *Fifo) void {
        self.init();
    }

    pub fn insert(self: *Fifo, node: *Node) FifoError!void {
        if (self.len >= capacity) return FifoError.ExceedMaxCapacity;

        self.nodes[self.len] = node;
        self.len += 1;
    }

    // lowest first
    pub fn insertSorted(self: *Fifo, node: *Node) FifoError!void {
        if (self.len >= capacity) return FifoError.ExceedMaxCapacity;
        if (self.len == 0) {
            try self.insert(node);
            return;
        }

        var index_to_insert: usize = 0;
        for (self.nodes[0..self.len], 0..) |e, i| {
            index_to_insert = i;
            const next_is_bigger: bool = switch (e.?.cost) {
                .infinity => true,
                .value => |v| v >= node.cost.value,
            };
            if (next_is_bigger)
                break;
        }

        var i: usize = self.len + 1;
        while (i > index_to_insert) : (i -= 1)
            self.nodes[i] = self.nodes[i - 1];

        self.nodes[index_to_insert] = node;
        self.len += 1;
    }

    pub fn pop(self: *Fifo) FifoError!*Node {
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
