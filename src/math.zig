const std = @import("std");

pub var random: std.Random = undefined;

pub const Point2D = struct {
    x: u32 = 0,
    y: u32 = 0,
};

pub fn initRand() !void {
    var prng: std.Random.DefaultPrng = .init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    random = prng.random();
}
