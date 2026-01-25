const print = @import("std").debug.print;
const std = @import("std");
const app = @import("App.zig");
const math = @import("math.zig");
const rl = @import("c.zig").rl;
const stdlib = @import("c.zig").stdlib;
const cast = @import("cast.zig").cast;
const Point2D = @import("math.zig").Point2D;

const BoxesError = error{OutOfBounds};

// export this as a global maybe
const State = enum {
    setup,
    running,
    done,
};
const SortType = enum {
    lowerCostFirst,
    higherCostFirst,
};

const elems = 400;
const box_w = app.width / elems;

pub const Boxes = struct {
    state: State = .setup,
    quit: bool = false,
    items: [elems]u16 = [_]u16{0} ** elems,

    // bubble sort stuff
    did_swap: bool = false,
    current_i: usize = 0,

    pub fn init(self: *Boxes) void {
        self.randomize();
    }

    pub fn destroy(self: *Boxes) void {
        _ = self;
    }

    fn randomize(self: *Boxes) void {
        for (&self.items) |*v| {
            v.* = @intCast(@mod(stdlib.rand(), app.height));
        }
    }

    pub fn run(self: *Boxes) void {
        self.quit = false;
        while (!self.quit) {
            self.input();
            self.frame();
            self.draw();
        }
    }

    fn input(self: *Boxes) void {
        switch (self.state) {
            State.setup => {
                if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_RIGHT)) {
                    self.quit = true;
                }
                if (rl.IsKeyReleased(rl.KEY_R)) {
                    self.randomize();
                }

                if (rl.IsKeyReleased(rl.KEY_S) or rl.IsKeyReleased(rl.KEY_ENTER)) {
                    self.transition(.running);
                }
            },
            State.running => {
                if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_RIGHT)) {
                    self.transition(.setup);
                }
            },
            State.done => {
                if (rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_RIGHT)) {
                    self.transition(.setup);
                }
            },
        }
    }

    fn frame(self: *Boxes) void {
        if (self.state != .running) return;
        self.bubbleSort(&self.items);
    }

    fn draw(self: *Boxes) void {
        rl.BeginDrawing();
        rl.ClearBackground(rl.WHITE);

        self.drawItems();

        if (self.state == .done) {
            rl.DrawText(
                "Done",
                app.width / 2,
                app.height / 2,
                24,
                rl.GREEN,
            );
        }

        rl.EndDrawing();
    }

    fn transition(self: *Boxes, to: State) void {
        switch (to) {
            State.setup => {
                self.randomize();
                self.state = .setup;
            },
            State.running => {
                self.current_i = 0;
                self.state = .running;
            },
            State.done => {
                self.state = .done;
            },
        }
    }

    fn drawItems(self: *Boxes) void {
        for (self.items, 0..) |e, i| {
            const col: i32 = cast(i32, i) * box_w;
            // const color = if (i % 2 == 0) rl.GRAY else rl.BLACK;
            rl.DrawRectangle(
                col,
                app.height - e,
                box_w,
                e,
                rl.GRAY,
            );
        }
    }

    pub fn bubbleSort(self: *Boxes, arr: []u16) void {
        while (self.current_i < arr.len - 1) : (self.current_i += 1) {
            if (arr[self.current_i] > arr[self.current_i + 1]) {
                const tmp: u16 = arr[self.current_i];
                arr[self.current_i] = arr[self.current_i + 1];
                arr[self.current_i + 1] = tmp;
                self.did_swap = true;

                // we return when there is an update that needs to be rendered
                return;
            }
        }

        if (self.did_swap) {
            self.current_i = 0;
            self.did_swap = false;
        } else {
            self.transition(.done);
        }
    }
};
