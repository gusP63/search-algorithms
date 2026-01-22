const print = @import("std").debug.print;
const math = @import("math.zig");
const rl = @import("c.zig").rl;
const Rectangle = math.Rectangle;
const Point2D = math.Point2D;
const Point2Df = math.Point2Df;

pub const Orientation = enum { horizontal, vertical };

pub const StyleProps = struct {
    foreground_color: rl.Color = rl.WHITE,
    background_color: rl.Color = rl.BLACK,
    border_color: ?rl.Color = null,
    margin_top: u8 = 0,
    margin_left: u8 = 0,
    margin_bottom: u8 = 0,
    margin_right: u8 = 0,
};

pub const DrawAreaList = struct { // top to bottom
    rect: Rectangle,
    orientation: Orientation,
    cursor_pos: Point2D,

    pub fn create(topleft: Point2D, width: u16, height: u16, orientation: Orientation) DrawAreaList {
        return .{ .rect = .{ .x = topleft.x, .y = topleft.y, .width = width, .height = height }, .orientation = orientation, .cursor_pos = .{ .x = topleft.x, .y = topleft.y } };
    }

    // will stretch the button to fill the list
    pub fn draw(self: *DrawAreaList, to_draw: *Button) void {
        // if (self.cursor_pos > self.rect.y + self.rect.height) return;
        self.cursor_pos.y += to_draw.style.margin_top;
        self.cursor_pos.x += to_draw.style.margin_left;

        switch (self.orientation) {
            .vertical => {
                to_draw.rect.width = self.rect.width;
            },
            .horizontal => {
                to_draw.rect.height = self.rect.height;
            },
        }

        to_draw.rect.x = self.cursor_pos.x;
        to_draw.rect.y = self.cursor_pos.y;

        rl.DrawRectangle(@intCast(self.cursor_pos.x), @intCast(self.cursor_pos.y), @intCast(to_draw.rect.width), @intCast(to_draw.rect.height), to_draw.style.background_color);
        rl.DrawText(@ptrCast(to_draw.label), @intCast(self.cursor_pos.x + to_draw.rect.width / 2), @intCast(self.cursor_pos.y + to_draw.rect.height / 2), 14, to_draw.style.foreground_color);

        switch (self.orientation) {
            .vertical => {
                self.cursor_pos.y += to_draw.rect.height;
            },
            .horizontal => {
                self.cursor_pos.x += to_draw.rect.width;
            },
        }
    }
};

pub const DrawAreaGrid = struct {
    rect: Rectangle,
    rows: u8,
    cols: u8,
    cursor_pos: Point2D,

    // pub fn create(topleft: Point2D, width: u16, height: u16) DrawAreaList {
    //     _ = topleft;
    // }

    //
    pub fn draw(self: *DrawAreaList, to_draw: *Button) void {
        _ = self;
        _ = to_draw;
        // if(cursor_pos > bottom_y) return;
        // self.cursor_pos.y += to_draw.margin_top;
        // self.cursor_pos.x += to_draw.margin_left;
        // rl.drawRect(self.cursor_pos.x, self.cursor_pos.y, to_draw.width, to_draw.height);
    }
};

pub const Button = struct {
    rect: Rectangle,
    label: []const u8,
    style: StyleProps,

    pub fn create(width: u16, height: u16, label: []const u8, style: StyleProps) Button {
        return .{ .rect = .{ .x = 0, .y = 0, .width = width, .height = height }, .label = label, .style = style };
    }

    pub fn isMouseInside(self: *Button, mouse_pos: Point2D) bool {
        return mouse_pos.x > self.rect.x and mouse_pos.x < self.rect.x + self.rect.width and mouse_pos.y > self.rect.y and mouse_pos.y < self.rect.y + self.rect.height;
    }
};
