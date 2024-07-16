local awful = require("awful")
local beautiful = require("beautiful")
local decorations = require("decorations")
local gears = require("gears")
local helpers = require("helpers")
local keys = require("keys")
local wibox = require("wibox")

-- This decoration theme will round clients according to your theme's
-- border_radius value
decorations.enable_rounding()

-- Add a titlebar
client.connect_signal("request::titlebars", function(c)
    awful
        .titlebar(c, {
            font = beautiful.titlebar_font,
            position = beautiful.titlebar_position,
            size = beautiful.titlebar_size,
            -- bg_focus = x.color0,
        })
        :setup({
            nil,
            nil,
            {
                awful.titlebar.widget.minimizebutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.closebutton(c),

                -- Create some extra padding at the edge
                helpers.horizontal_pad(dpi(9)),

                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
        })
end)
