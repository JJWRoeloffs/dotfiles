local awful = require("awful")
local beautiful = require("beautiful")
local decorations = require("decorations")
local gears = require("gears")
local helpers = require("helpers")
local keys = require("keys")
local wibox = require("wibox")

-- This decoration theme will round clients according to your theme's
-- border_radius value
-- Disable this if using `picom` to round your corners
-- decorations.enable_rounding()

-- Button configuration
local gen_button_size = dpi(7)
local gen_button_margin = dpi(7)
local gen_button_color_unfocused = x.color0
local gen_button_shape = gears.shape.circle

-- Add a titlebar
client.connect_signal("request::titlebars", function(c)
    awful
        .titlebar(c, {
            font = beautiful.titlebar_font,
            position = beautiful.titlebar_position,
            size = beautiful.titlebar_size,
        })
        :setup({
            nil,
            nil,
            {
                decorations.button(
                    c,
                    gen_button_shape,
                    x.color6,
                    gen_button_color_unfocused,
                    x.color6,
                    gen_button_size,
                    gen_button_margin,
                    "maximize"
                ),
                decorations.button(
                    c,
                    gen_button_shape,
                    x.color13,
                    gen_button_color_unfocused,
                    x.color13,
                    gen_button_size,
                    gen_button_margin,
                    "close"
                ),

                -- Create some extra padding at the edge
                helpers.horizontal_pad(gen_button_margin / 2),

                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
        })
end)

-- round corner
decorations.enable_rounding()
