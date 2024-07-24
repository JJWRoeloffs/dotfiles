local apps = require("apps")
local awful = require("awful")
local decorations = require("decorations")
local gears = require("gears")
local naughty = require("naughty")

local helpers = require("helpers")

local keys = {}

-- Mod keys
local superkey = "Mod4"
local altkey = "Mod1"
local ctrlkey = "Control"
local shiftkey = "Shift"

-- {{{ Key bindings
keys.globalkeys = gears.table.join(
    -- Focus client by direction (hjkl keys)
    awful.key({ superkey }, "j", function()
        awful.client.focus.bydirection("down")
    end, { description = "focus down", group = "client" }),
    awful.key({ superkey }, "k", function()
        awful.client.focus.bydirection("up")
    end, { description = "focus up", group = "client" }),
    awful.key({ superkey }, "h", function()
        awful.client.focus.bydirection("left")
    end, { description = "focus left", group = "client" }),
    awful.key({ superkey }, "l", function()
        awful.client.focus.bydirection("right")
    end, { description = "focus right", group = "client" }),

    -- Focus client by index (cycle through clients)
    awful.key({ superkey }, "z", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "client" }),

    awful.key({ superkey, shiftkey }, "z", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus next by index", group = "client" }),

    -- Kill all visible clients for the current tag
    awful.key({ superkey, ctrlkey, shiftkey }, "q", function()
        local clients = awful.screen.focused().clients
        for _, c in pairs(clients) do
            c:kill()
        end
    end, {
        description = "kill all visible clients for the current tag",
        group = "client",
    }),

    -- Resize focused client or layout factor
    awful.key({ superkey, ctrlkey }, "j", function(c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ superkey, ctrlkey }, "k", function(c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ superkey, ctrlkey }, "h", function(c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ superkey, ctrlkey }, "l", function(c)
        helpers.resize_dwim(client.focus, "right")
    end),

    -- Switch to screens
    awful.key({ superkey, altkey }, "j", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "screen" }),

    awful.key({ superkey, altkey }, "k", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "screen" }),

    awful.key({ superkey }, "q", function()
        awful.screen.focus(1)
    end, { description = "focus the first screen", group = "screen" }),

    awful.key({ superkey }, "w", function()
        awful.screen.focus(2)
    end, { description = "focus the second screen", group = "screen" }),

    -- Urgent or Undo:
    -- Jump to urgent client or (if there is no such client) go back
    -- to the last tag
    awful.key({ superkey }, "u", function()
        uc = awful.client.urgent.get()
        -- If there is no urgent client, go back to last tag
        if uc == nil then
            awful.tag.history.restore()
        else
            awful.client.urgent.jumpto()
        end
    end, { description = "jump to urgent client", group = "client" }),

    awful.key({ superkey }, "x", function()
        awful.tag.history.restore()
    end, { description = "go back", group = "tag" }),

    -- Spawn terminal
    awful.key({ superkey }, "Return", function()
        awful.spawn(user.terminal)
    end, { description = "open a terminal", group = "launcher" }),

    -- Reload Awesome
    awful.key(
        { superkey, shiftkey },
        "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),
    -- Show keybindinds
    awful.key(
        { superkey, shiftkey, ctrlkey },
        "s",
        require("awful.hotkeys_popup.widget").show_help,
        { description = "show help", group = "awesome" }
    ),

    -- Quit Awesome
    -- Logout, Shutdown, Restart, Suspend, Lock
    awful.key({ superkey }, "Escape", function()
        exit_screen_show()
    end, { description = "quit awesome", group = "awesome" }),

    -- Number of master clients (set to hyper on the Moonlander)
    awful.key({ superkey, altkey, shiftkey, ctrlkey }, "h", function()
        awful.tag.incnmaster(1, nil, true)
    end, { description = "increase the number of master clients", group = "layout" }),
    awful.key({ superkey, altkey, shiftkey, ctrlkey }, "l", function()
        awful.tag.incnmaster(-1, nil, true)
    end, { description = "decrease the number of master clients", group = "layout" }),

    -- Number of columns
    awful.key({ superkey, altkey, shiftkey, ctrlkey }, "k", function()
        awful.tag.incncol(1, nil, true)
    end, { description = "increase the number of columns", group = "layout" }),
    awful.key({ superkey, altkey, shiftkey, ctrlkey }, "j", function()
        awful.tag.incncol(-1, nil, true)
    end, { description = "decrease the number of columns", group = "layout" }),

    --awful.key({ superkey,           }, "space", function () awful.layout.inc( 1)                end,
    --{description = "select next", group = "layout"}),
    --awful.key({ superkey, shiftkey   }, "space", function () awful.layout.inc(-1)                end,
    --{description = "select previous", group = "layout"}),

    awful.key({ superkey, shiftkey }, "i", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            client.focus = c
        end
    end, { description = "restore minimized", group = "client" }),

    -- Prompt
    --awful.key({ superkey },            "d",     function () awful.screen.focused().mypromptbox:run() end,
    --{description = "run prompt", group = "launcher"}),
    -- Run program (d for dmenu ;)
    awful.key({ superkey }, "d", function()
        awful.spawn.with_shell("rofi -matching fuzzy -show combi")
    end, { description = "rofi launcher", group = "launcher" }),

    -- Dismiss notifications and elements that connect to the dismiss signal
    awful.key({ ctrlkey }, "space", function()
        awesome.emit_signal("elemental::dismiss")
        naughty.destroy_all_notifications()
    end, { description = "dismiss notification", group = "notifications" }),

    -- Menubar
    --awful.key({ superkey, ctrlkey }, "b", function() menubar.show() end,
    --{description = "show the menubar", group = "launcher"}),

    -- Volume Control with volume keys
    awful.key({}, "XF86AudioMute", function()
        helpers.volume_control(0)
    end, { description = "(un)mute volume", group = "volume" }),
    awful.key({}, "XF86AudioLowerVolume", function()
        helpers.volume_control(-5)
    end, { description = "lower volume", group = "volume" }),
    awful.key({}, "XF86AudioRaiseVolume", function()
        helpers.volume_control(5)
    end, { description = "raise volume", group = "volume" }),

    -- Screenshots
    awful.key({}, "Print", function()
        apps.screenshot("full")
    end, { description = "take full screenshot", group = "screenshots" }),
    awful.key({ superkey, shiftkey }, "c", function()
        apps.screenshot("selection")
    end, { description = "select area to capture", group = "screenshots" }),
    awful.key({ superkey, ctrlkey }, "c", function()
        apps.screenshot("clipboard")
    end, { description = "select area to copy to clipboard", group = "screenshots" }),
    awful.key({ superkey }, "Print", function()
        apps.screenshot("browse")
    end, { description = "browse screenshots", group = "screenshots" }),
    awful.key(
        { superkey, shiftkey },
        "Print",
        function()
            apps.screenshot("gimp")
        end,
        { description = "edit most recent screenshot with gimp", group = "screenshots" }
    ),
    -- Toggle tray visibility
    -- awful.key({ superkey }, "=", function()
    --     tray_toggle()
    -- end, { description = "toggle tray visibility", group = "custom" }),

    -- Max layout
    -- Single tap: Set max layout
    -- Double tap: Also disable floating for ALL visible clients in the tag
    awful.key({ superkey, shiftkey }, "w", function()
        awful.layout.set(awful.layout.suit.max)
        helpers.single_double_tap(nil, function()
            local clients = awful.screen.focused().clients
            for _, c in pairs(clients) do
                c.floating = false
            end
        end)
    end, { description = "set max layout", group = "tag" }),
    -- Tiling
    -- Single tap: Set tiled layout
    -- Double tap: Also disable floating for ALL visible clients in the tag
    awful.key({ superkey }, "s", function()
        awful.layout.set(awful.layout.suit.tile)
        helpers.single_double_tap(nil, function()
            local clients = awful.screen.focused().clients
            for _, c in pairs(clients) do
                c.floating = false
            end
        end)
    end, { description = "set tiled layout", group = "tag" }),
    -- Set floating layout
    awful.key({ superkey, shiftkey }, "s", function()
        awful.layout.set(awful.layout.suit.floating)
    end, { description = "set floating layout", group = "tag" }),
    -- Toggle night mode
    awful.key(
        { superkey },
        "n",
        apps.night_mode,
        { description = "Toggle Night filter", group = "launcher" }
    )
)

keys.clientkeys = gears.table.join(
    -- Move to edge or swap by direction
    awful.key({ superkey, shiftkey }, "j", function(c)
        helpers.move_client_dwim(c, "down")
    end),
    awful.key({ superkey, shiftkey }, "k", function(c)
        helpers.move_client_dwim(c, "up")
    end),
    awful.key({ superkey, shiftkey }, "h", function(c)
        helpers.move_client_dwim(c, "left")
    end),
    awful.key({ superkey, shiftkey }, "l", function(c)
        helpers.move_client_dwim(c, "right")
    end),

    -- Single tap: Center client
    -- Double tap: Center client + Floating + Resize
    awful.key({ superkey }, "c", function(c)
        awful.placement.centered(c, { honor_workarea = true, honor_padding = true })
        helpers.single_double_tap(nil, function()
            helpers.float_and_resize(c, screen_width * 0.65, screen_height * 0.9)
        end)
    end),

    -- Relative move client
    awful.key({ superkey, shiftkey, ctrlkey }, "j", function(c)
        c:relative_move(0, dpi(20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "k", function(c)
        c:relative_move(0, dpi(-20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "h", function(c)
        c:relative_move(dpi(-20), 0, 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "l", function(c)
        c:relative_move(dpi(20), 0, 0, 0)
    end),

    -- Close single client
    awful.key({ superkey, shiftkey }, "q", function(c)
        c:kill()
    end, { description = "close", group = "client" }),

    -- Toggle titlebars (for focused client only)
    awful.key({ superkey }, "t", function(c)
        decorations.cycle(c)
    end, { description = "toggle titlebar", group = "client" }),
    -- Toggle titlebars (for all visible clients in selected tag)
    awful.key({ superkey, shiftkey }, "t", function(c)
        local clients = awful.screen.focused().clients
        for _, c in pairs(clients) do
            decorations.cycle(c)
        end
    end, { description = "toggle titlebar", group = "client" }),

    -- Toggle fullscreen
    awful.key({ superkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = "toggle fullscreen", group = "client" }),

    -- F for focused view
    awful.key({ superkey, ctrlkey }, "f", function(c)
        helpers.float_and_resize(c, screen_width * 0.7, screen_height * 0.75)
    end, { description = "focus mode", group = "client" }),
    -- V for vertical view
    awful.key({ superkey, ctrlkey }, "v", function(c)
        helpers.float_and_resize(c, screen_width * 0.45, screen_height * 0.90)
    end, { description = "focus mode", group = "client" }),
    -- T for tiny window
    awful.key({ superkey, ctrlkey }, "t", function(c)
        helpers.float_and_resize(c, screen_width * 0.3, screen_height * 0.35)
    end, { description = "tiny mode", group = "client" }),
    -- N for normal size (good for terminals)
    awful.key({ superkey, ctrlkey }, "n", function(c)
        helpers.float_and_resize(c, screen_width * 0.45, screen_height * 0.5)
    end, { description = "normal mode", group = "client" }),

    -- Toggle floating
    awful.key({ superkey, ctrlkey }, "space", function(c)
        local layout_is_floating = (
            awful.layout.get(mouse.screen) == awful.layout.suit.floating
        )
        if not layout_is_floating then
            awful.client.floating.toggle()
        end
    end, { description = "toggle floating", group = "client" }),

    -- Set master
    awful.key({ superkey, ctrlkey }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end, { description = "move to master", group = "client" }),

    -- P for pin: keep on top OR sticky
    -- On top
    awful.key({ superkey, shiftkey }, "p", function(c)
        c.ontop = not c.ontop
    end, { description = "toggle keep on top", group = "client" }),
    -- Sticky
    awful.key({ superkey, ctrlkey }, "p", function(c)
        c.sticky = not c.sticky
    end, { description = "toggle sticky", group = "client" }),

    -- Minimize
    awful.key({ superkey }, "i", function(c)
        c.minimized = true
    end, { description = "minimize", group = "client" }),

    -- Maximize
    awful.key({ superkey }, "m", function(c)
        c.maximized = not c.maximized
    end, { description = "(un)maximize", group = "client" }),
    awful.key({ superkey, ctrlkey }, "m", function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, { description = "(un)maximize vertically", group = "client" }),
    awful.key({ superkey, shiftkey }, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, { description = "(un)maximize horizontally", group = "client" }),

    -- Move client to screens
    awful.key({ superkey, altkey }, "l", function(c)
        helpers.move_client_to_screen(
            c,
            gears.math.cycle(screen:count(), c.screen.index + 1)
        )
    end, { description = "move to next screen", group = "screen" }),
    awful.key({ superkey, altkey }, "h", function(c)
        helpers.move_client_to_screen(
            c,
            gears.math.cycle(screen:count(), c.screen.index - 1)
        )
    end, { description = "move to previous screen", group = "screen" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local ntags = 10
for i = 1, ntags do
    keys.globalkeys = gears.table.join(
        keys.globalkeys,
        -- View tag only.
        awful.key({ superkey }, "#" .. i + 9, function()
            -- Tag back and forth
            helpers.tag_back_and_forth(i)

            -- Simple tag view
            -- local tag = mouse.screen.tags[i]
            -- if tag then
            -- tag:view_only()
            -- end
        end, { description = "view tag #" .. i, group = "tag" }),

        -- Move client to tag.
        awful.key({ superkey, shiftkey }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                    helpers.tag_back_and_forth(i)
                end
            end
        end, { description = "move focused client to tag #" .. i, group = "tag" }),

        -- Move all visible clients to tag and focus that tag
        awful.key({ superkey, ctrlkey }, "#" .. i + 9, function()
            local tag = client.focus.screen.tags[i]
            local clients = awful.screen.focused().clients
            if tag then
                for _, c in pairs(clients) do
                    c:move_to_tag(tag)
                end
                tag:view_only()
            end
        end, {
            description = "move all visible clients to tag #" .. i,
            group = "tag",
        })
    )
    keys.clientkeys = gears.table.join(
        keys.clientkeys,
        -- move client to screens
        awful.key({ superkey, altkey }, "#" .. i + 9, function(c)
            helpers.move_client_to_screen(c, i)
        end, { description = "move to screen #" .. i, group = "screen" })
    )
end

-- Mouse buttons on the client (whole window, not just titlebar)
keys.clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        client.focus = c
    end),
    awful.button({ superkey }, 1, awful.mouse.client.move),
    -- awful.button({ superkey }, 2, function (c) c:kill() end),
    awful.button({ superkey }, 3, function(c)
        client.focus = c
        awful.mouse.client.resize(c)
        -- awful.mouse.resize(c, nil, {jump_to_corner=true})
    end),

    -- Super + scroll = Change client opacity
    awful.button({ superkey }, 4, function(c)
        c.opacity = c.opacity + 0.1
    end),
    awful.button({ superkey }, 5, function(c)
        c.opacity = c.opacity - 0.1
    end)
)

-- Mouse buttons on the tasklist
-- Use 'Any' modifier so that the same buttons can be used in the floating
-- tasklist displayed by the window switcher while the superkey is pressed
keys.tasklist_buttons = gears.table.join(
    awful.button({ "Any" }, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
        end
    end),
    -- Middle mouse button closes the window (on release)
    awful.button({ "Any" }, 2, nil, function(c)
        c:kill()
    end),
    awful.button({ "Any" }, 3, function(c)
        c.minimized = true
    end),
    awful.button({ "Any" }, 4, function()
        awful.client.focus.byidx(-1)
    end),
    awful.button({ "Any" }, 5, function()
        awful.client.focus.byidx(1)
    end),

    -- Side button up - toggle floating
    awful.button({ "Any" }, 9, function(c)
        c.floating = not c.floating
    end),
    -- Side button down - toggle ontop
    awful.button({ "Any" }, 8, function(c)
        c.ontop = not c.ontop
    end)
)

-- Mouse buttons on a tag of the taglist widget
keys.taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
        -- t:view_only()
        helpers.tag_back_and_forth(t.index)
    end),
    awful.button({ superkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    -- awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({}, 3, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ superkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t)
        awful.tag.viewprev(t.screen)
    end),
    awful.button({}, 5, function(t)
        awful.tag.viewnext(t.screen)
    end)
)

-- Mouse buttons on the primary titlebar of the window
keys.titlebar_buttons = gears.table.join(
    -- Left button - move
    -- (Double tap - Toggle maximize) -- A little BUGGY
    awful.button({}, 1, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        awful.mouse.client.move(c)
        -- local function single_tap()
        --   awful.mouse.client.move(c)
        -- end
        -- local function double_tap()
        --   gears.timer.delayed_call(function()
        --       c.maximized = not c.maximized
        --   end)
        -- end
        -- helpers.single_double_tap(single_tap, double_tap)
        -- helpers.single_double_tap(nil, double_tap)
    end),
    -- Middle button - close
    awful.button({}, 2, function()
        local c = mouse.object_under_pointer()
        c:kill()
    end),
    -- Right button - resize
    awful.button({}, 3, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        awful.mouse.client.resize(c)
        -- awful.mouse.resize(c, nil, {jump_to_corner=true})
    end),
    -- Side button up - toggle floating
    awful.button({}, 9, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        --awful.placement.centered(c,{honor_padding = true, honor_workarea=true})
        c.floating = not c.floating
    end),
    -- Side button down - toggle ontop
    awful.button({}, 8, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        c.ontop = not c.ontop
        -- Double Tap - toggle sticky
        -- local function single_tap()
        --   c.ontop = not c.ontop
        -- end
        -- local function double_tap()
        --   c.sticky = not c.sticky
        -- end
        -- helpers.single_double_tap(single_tap, double_tap)
    end)
)

-- }}}

-- Set root (desktop) keys
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

return keys
