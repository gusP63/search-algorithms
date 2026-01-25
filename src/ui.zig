const std = @import("std");
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
    cursor_pos: Point2D = .{ .x = 0, .y = 0 },

    // will stretch the button to fill the list
    pub fn draw(self: *DrawAreaList, to_draw: *Button) void {
        if (self.cursor_pos.x == 0 and self.cursor_pos.y == 0) {
            self.cursor_pos.x = self.rect.x;
            self.cursor_pos.y = self.rect.y;
        }

        self.cursor_pos.y += to_draw.style.margin_top;
        self.cursor_pos.x += to_draw.style.margin_left;
        to_draw.rect.x = self.cursor_pos.x;
        to_draw.rect.y = self.cursor_pos.y;

        switch (self.orientation) {
            .vertical => {
                to_draw.rect.width = self.rect.width;
            },
            .horizontal => {
                to_draw.rect.height = self.rect.height;
            },
        }

        rl.DrawRectangle(to_draw.rect.x, to_draw.rect.y, to_draw.rect.width, to_draw.rect.height, to_draw.style.background_color);
        rl.DrawText(to_draw.label.ptr, to_draw.rect.x + to_draw.rect.width / 2, to_draw.rect.y + to_draw.rect.height / 2, 14, to_draw.style.foreground_color);

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
    cursor_pos: Point2D = .{ .x = 0, .y = 0 },
    items_drawn: u8 = 0,

    pub fn draw(self: *DrawAreaGrid, to_draw: *Button) void {
        if (self.items_drawn >= self.rows * self.cols) return;
        if (self.cursor_pos.x == 0 and self.cursor_pos.y == 0) {
            self.cursor_pos.x = self.rect.x;
            self.cursor_pos.y = self.rect.y;
        }
        const w = self.rect.width / self.cols;
        const h = self.rect.height / self.rows;

        //TODO: add spacing between items (at the grid level, not the button)
        to_draw.rect.width = w;
        to_draw.rect.height = h;
        to_draw.rect.x = self.cursor_pos.x;
        to_draw.rect.y = self.cursor_pos.y;

        rl.DrawRectangle(to_draw.rect.x, to_draw.rect.y, to_draw.rect.width, to_draw.rect.height, to_draw.style.background_color);
        rl.DrawText(to_draw.label.ptr, to_draw.rect.x + to_draw.rect.width / 2, to_draw.rect.y + to_draw.rect.height / 2, 14, to_draw.style.foreground_color);
        self.items_drawn += 1;

        const col = self.items_drawn % self.cols;
        self.cursor_pos.x = self.rect.x + w * col;
        if (col == 0) self.cursor_pos.y += h;
    }
};

pub const Button = struct {
    rect: Rectangle,
    label: []const u8,
    style: StyleProps,

    pub fn create(width: u32, height: u32, label: []const u8, style: StyleProps) Button {
        return .{ .rect = .{ .x = 0, .y = 0, .width = width, .height = height }, .label = label, .style = style };
    }

    pub fn isMouseInside(self: *Button, mouse_pos: Point2D) bool {
        return mouse_pos.x > self.rect.x and mouse_pos.x < self.rect.x + self.rect.width and mouse_pos.y > self.rect.y and mouse_pos.y < self.rect.y + self.rect.height;
    }
};
