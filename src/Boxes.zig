const print = @import("std").debug.print;
const app = @import("App.zig");
const rl = @import("c.zig").rl;
const Point2D = @import("math.zig").Point2D;

const BoxesError = error{OutOfBounds};

const State = enum { setup, running, done };

pub const Boxes = struct {
    pub fn create() Boxes {}

    pub fn destroy(self: *Boxes) void {
        _ = self;
    }

    pub fn run(self: *Boxes) void {
        _ = self;
    }
};
