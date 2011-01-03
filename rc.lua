

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")
require("shifty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/nick/.config/awesome/theme.lua")

-- theme.wallpaper_cmd = { "awsetbg /home/nick/alltech/Allgemein_Programming/Clojure/clojure.png" }

-- This is used later as the default terminal and editor to run.
terminal = "urxvtcd"
browser = "firefox"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max
}


-- {{{ Shifty configuration
-- tag settings
shifty.config.tags = {
    ["term"] = { position = 1, exclusive = true, spawn = terminal, },
    ["web"]  = { position = 2, exclusive = true, spawn = browser, layout = awful.layout.suit.max, },
}

-- client settings
-- order here matters, early rules will be applied first
shifty.config.apps = {
         { match = { "Navigator","Vimperator","Gran Paradiso","Firefox","Iceweasel"} , tag = "web" } ,
         { match = { "xterm", "urxvt"} , honorsizehints = false, slave = true, tag = "term" } ,
         { match = { "pcmanfm" }, slave = true } ,
         { match = { "" }, buttons = {
                             button({ }, 1, function (c) client.focus = c; c:raise() end),
                             button({ modkey }, 1, function (c) awful.mouse.client.move() end),
                             button({ modkey }, 3, awful.mouse.client.resize ), }, },
}

-- tag defaults
shifty.config.defaults = {
  layout = awful.layout.suit.tile.bottom,
  ncol = 1,
  mwfact = 0.60,
  floatBars=true,
}

shifty.init()
-- }}}


-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- net up and down load widget
 netwidget = widget({ type = "textbox" })
 -- Register widget
 vicious.register(netwidget, vicious.widgets.net, 'NET: <span color="#EE6363">${eth0 down_kb}</span> <span color="#556B2F">${eth0 up_kb}</span> kB/s ', 3)


-- battery widget

mybattmon = widget({ type = "textbox", name = "mybattmon", align = "right" })
function battery_status ()
    local output={} --output buffer
    local fd=io.popen("acpitool -b", "r") --list present batteries
    local line=fd:read()
    while line do --there might be several batteries.
        local battery_num = string.match(line, "Battery \#(%d+)")
        local battery_load = string.match(line, " (%d*\.%d+)%%")
        local time_rem = string.match(line, "(%d+\:%d+)\:%d+")
	local discharging
	if string.match(line, "discharging")=="discharging" then --discharging: always red
		discharging="<span color=\"#EE6363\">"
	elseif tonumber(battery_load)>85 then --almost charged
		discharging="<span color=\"#556B2F\">"
	else --charging
		discharging="<span color=\"#DAA520\">"
	end
        if battery_num and battery_load and time_rem then
            table.insert(output,discharging.."BAT#"..battery_num.." "..battery_load.."% "..time_rem.."</span>")
        elseif battery_num and battery_load then --remaining time unavailable
            table.insert(output,discharging.."BAT#"..battery_num.." "..battery_load.."%</span>")
        end --even more data unavailable: we might be getting an unexpected output format, so let's just skip this line.
        line=fd:read() --read next line
    end
    return table.concat(output,"|") 
end
mybattmon.text = " " .. battery_status() .. " "
my_battmon_timer=timer({timeout=30})
my_battmon_timer:add_signal("timeout", function()
    --mytextbox.text = " " .. os.date() .. " "
    mybattmon.text = " " .. battery_status() .. " "
end)
my_battmon_timer:start()



-- mpd widget
mpdwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(mpdwidget, vicious.widgets.mpd,
    function (widget, args)
        if args["{state}"] == "Stop" then 
            return " - "
        else 
            return args["{Artist}"]..' - '.. args["{Title}"]
        end
    end, 10)


-- Internet widget

mynet= widget({type = "textbox", name = "Internet VPN"})

function iss (IP_range)
	local fd = io.popen("~/.config/awesome/checknet.sh", "r")
	local line = fd:read()
	if string.find(line, "Offline") then
		return "<span color=\"#EE6363\">" .. line  .. "</span>"
	end
	if string.find(line, "Internet") then
		return "<span color=\"#DAA520\">".. line .. "</span>"
	end
	if string.find(line, "VPN") then
		return "<span color=\"#556B2F\">" ..  line .. "</span>" 
	end
end
mynet.text = iss()
my_net_timer=timer({timeout=10})
my_net_timer:add_signal("timeout", function()
    mynet.text = iss()
end)
my_net_timer:start()

-- MPD
mympd = widget({type = "textbox"})
mympd.text = "MPD: "

-- my double point widget
mydp = widget({ type = "textbox" })
mydp.text = " | "

-- memory widget
memwidget2 = widget({ type = "textbox" })
-- Register widget
vicious.register(memwidget2, vicious.widgets.mem, " RAM: $1%", 13)


-- Volume widget
volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume, " $1% ", 2, "Master")

volwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("amixer -q set Master toggle", false) end),
    awful.button({ }, 3, function () awful.util.spawn("urxvt -e alsamixer", true) end),
    awful.button({ }, 4, function () awful.util.spawn("amixer -q set Master 1dB+", false) end),
    awful.button({ }, 5, function () awful.util.spawn("amixer -q set Master 1dB-", false) end)
))

-- date widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%b %d, %R", 60)

-- Initialize widget

textcpuwidget = widget({type = "textbox"})
textcpuwidget.text = "CPU: "

cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#000000")
cpuwidget:set_color("#FF5656")
cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s], mydp,
			textcpuwidget, cpuwidget,mydp,
			memwidget2,mydp,
			mybattmon,mydp,
			netwidget, mynet, mydp,
			mympd, mpdwidget, volwidget, mydp,
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
		datewidget,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
	awful.key({"Control", "Shift"}, "Delete", function () awful.util.spawn("slock") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
--keynumber = 0
--for s = 1, screen.count() do
--   keynumber = math.min(9, math.max(#tags[s], keynumber));
--end
--
---- Bind all key numbers to tags.
---- Be careful: we use keycodes to make it works on any keyboard layout.
---- This should map on the top row of your keyboard, usually 1 to 9.
--for i = 1, keynumber do
--    globalkeys = awful.util.table.join(globalkeys,
--        awful.key({ modkey }, "#" .. i + 9,
--                  function ()
--                        local screen = mouse.screen
--                        if tags[screen][i] then
--                            awful.tag.viewonly(tags[screen][i])
--                        end
--                  end),
--        awful.key({ modkey, "Control" }, "#" .. i + 9,
--                  function ()
--                      local screen = mouse.screen
--                      if tags[screen][i] then
--                          awful.tag.viewtoggle(tags[screen][i])
--                      end
--                  end),
--        awful.key({ modkey, "Shift" }, "#" .. i + 9,
--                  function ()
--                      if client.focus and tags[client.focus.screen][i] then
--                          awful.client.movetotag(tags[client.focus.screen][i])
--                      end
--                  end),
--        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
--                  function ()
--                      if client.focus and tags[client.focus.screen][i] then
--                          awful.client.toggletag(tags[client.focus.screen][i])
--                      end
--                  end))
--end

-- {{{ bindings / global / shifty.getpos
for i=1, ( shifty.config.maxtags or 9 ) do
  
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey }, i,
  function ()
    local t = awful.tag.viewonly(shifty.getpos(i))
  end))
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control" }, i,
  function ()
    local t = shifty.getpos(i)
    t.selected = not t.selected
  end))
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control", "Shift" }, i,
  function ()
    if client.focus then
      awful.client.toggletag(shifty.getpos(i))
    end
  end))
  -- move clients to other tags
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Shift" }, i,
    function ()
      if client.focus then
        local t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
      end
    end))
end
-- }}}


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
shifty.config.globalkeys = globalkeys
shifty.config.clientkeys = clientkeys
-- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
--awful.hooks.focus.register(function (c)
--    if not awful.client.ismarked(c) then
--        c.border_color = beautiful.border_focus
--    end
--end)
--
---- Hook function to execute when unfocusing a client.
--awful.hooks.unfocus.register(function (c)
--    if not awful.client.ismarked(c) then
--        c.border_color = beautiful.border_normal
--    end
--end)
--
---- Hook function to execute when marking a client
--awful.hooks.marked.register(function (c)
--    c.border_color = beautiful.border_marked
--end)
--
---- Hook function to execute when unmarking a client.
--awful.hooks.unmarked.register(function (c)
--    c.border_color = beautiful.border_focus
--end)
--
---- Hook function to execute when the mouse enters a client.
--awful.hooks.mouse_enter.register(function (c)
--    -- Sloppy focus, but disabled for magnifier layout
--    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--        and awful.client.focus.filter(c) then
--        client.focus = c
--    end
--end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
--awful.hooks.arrange.register(function (screen)
--    local layout = awful.layout.getname(awful.layout.get(screen))
--    if layout and beautiful["layout_" ..layout] then
--        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
--    else
--        mylayoutbox[screen].image = nil
--    end
--
--    -- Give focus to the latest client in history if no window has focus
--    -- or if the current window is a desktop or a dock one.
--    if not client.focus then
--        local c = awful.client.focus.history.get(screen, 0)
--        if c then client.focus = c end
--    end
--end)

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

shifty.init()
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- }}}
client.add_signal("focus", function(c)
  c.border_color = beautiful.border_focus
  if c.opacity < 1.0 then
    c.opacity = beautiful.opacity_focus
  end
end)

client.add_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
  if c.opacity < 1.0 then
    c.opacity = beautiful.opacity_normal
  end
end)
