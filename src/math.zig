const std = @import("std");

pub const Point2D = struct {
    x: u31 = 0,
    y: u31 = 0,
};

pub const Point2Df = struct {
    x: f32 = 0,
    y: f32 = 0,
};

pub const Rectangle = struct {
    x: u31,
    y: u31,
    width: u16,
    height: u16,
};

pub var random: std.Random = undefined;

pub fn initRand() !void {
    const seed = @abs(std.time.microTimestamp());
    var prng = std.Random.DefaultPrng.init(seed);
    random = prng.random();
}
