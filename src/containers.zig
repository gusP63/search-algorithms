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

    const SortType = enum { lowerCostFirst, higherCostFirst };

    pub fn sort(self: *Fifo, how: SortType) void {
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

    //TODO: remove this
    pub fn bubbleSort(self: *Fifo, shouldSwap: *const fn (e1: Node, e2: Node) bool) void {
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
};
