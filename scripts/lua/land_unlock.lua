local is_window_opened = false
local hovered_group_id = nil
local windows_positions = {}
local current_ui_path = {}

function client_start(framework)
    open_unlock_window(framework)
    framework:add_theme("land_unlock_locked_biome", locked_biome_theme)
    framework:add_theme("land_unlock_biome_unlocker", unlocker_biome_theme)
    framework:add_window_theme("land_unlock_locked_group", land_unlock_locked_group)

    framework:new_window("Land Unlock")
    framework:show_title_bar("Land Unlock", true)
    framework:add_scroll("Land Unlock", "Land Unlock Scroll", {1000, 500}, nil)
    framework:add_vertical("Land Unlock", "Groups List", {1000, 500}, "Land Unlock Scroll")
    framework:set_window_size("Land Unlock", {1000, 500})

    -- groups
    framework:add_horizontal("Land Unlock", "Biome Group 1", {100, 100}, "Groups List")
    framework:add_button("Land Unlock", "Biome 1 of Biome Group 1", "1", {75, 75}, "Biome Group 1")
    framework:set_widget_spacing("Land Unlock", "Biome 1 of Biome Group 1", 10)
    framework:add_horizontal("Land Unlock", "Biome Group 2", {100, 100}, "Groups List")
    framework:add_button("Land Unlock", "Biome 1 of Biome Group 2", "1", {75, 75}, "Biome Group 2")
    framework:set_widget_spacing("Land Unlock", "Biome 1 of Biome Group 2", 10)
    framework:add_horizontal("Land Unlock", "Biome Group 3", {100, 100}, "Groups List")
    framework:add_button("Land Unlock", "Biome 1 of Biome Group 3", "1", {75, 75}, "Biome Group 3")
    framework:set_widget_spacing("Land Unlock", "Biome 1 of Biome Group 3", 10)
    framework:add_horizontal("Land Unlock", "Biome Group 4", {100, 100}, "Groups List")
    framework:add_button("Land Unlock", "Biome 1 of Biome Group 4", "1", {75, 75}, "Biome Group 4")
    framework:set_widget_spacing("Land Unlock", "Biome 1 of Biome Group 4", 10)
    framework:add_horizontal("Land Unlock", "Biome Group 5", {100, 100}, "Groups List")
    framework:add_button("Land Unlock", "Biome 1 of Biome Group 5", "1", {75, 75}, "Biome Group 5")
    framework:set_widget_spacing("Land Unlock", "Biome 1 of Biome Group 5", 10)
    framework:add_horizontal("Land Unlock", "Biome Group 6", {100, 100}, "Groups List")
    framework:add_button("Land Unlock", "Biome 1 of Biome Group 6", "1", {75, 75}, "Biome Group 6")
    framework:set_widget_spacing("Land Unlock", "Biome 1 of Biome Group 6", 10)
    framework:add_horizontal("Land Unlock", "Biome Group 7", {100, 100}, "Groups List")
    framework:add_button("Land Unlock", "Biome 1 of Biome Group 7", "1", {75, 75}, "Biome Group 7")
    framework:set_widget_spacing("Land Unlock", "Biome 1 of Biome Group 7", 10)
end

function client_update(framework)
end

function client_render(framework)

end

function server_start(framework)
end

function server_update(framework)
end

function reg_message(message, framework)
    local message_id = message:message_id()
end

function open_unlock_window(framework)
    is_window_opened = true
end

function close_unlock_window(framework)
end

--[[
function get_biome_group_y_level(framework, current_level, biome_groups, group_unlocker_biome)
    local unlocker_biome = framework:get_global_system_value("Biomes_" .. group_unlocker_biome .. "_Biome")
    if unlocker_biome == nil then
        return current_level
    elseif #unlocker_biome == 0 then
        return current_level
    end

    for _, group in pairs(biome_groups) do
        local group_biomes = group[2]
        local new_group_unlocker_biome = group[3]
        for _, biome in pairs(group_biomes) do
            if biome == group_unlocker_biome then
                return get_biome_group_y_level(framework, current_level + 1, biome_groups, new_group_unlocker_biome)
            end
        end
    end
end
--]]


unlocker_biome_theme = [[
{
  "dark_mode": true,
  "override_text_color": null,
  "widgets": {
    "noninteractive": {
      "bg_fill": [
        255,
        201,
        201,
        255
      ],
      "weak_bg_fill": [
        255,
        201,
        201,
        255
      ],
      "bg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "rounding": {
        "nw": 5.0,
        "ne": 5.0,
        "sw": 5.0,
        "se": 5.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "expansion": 0.0
    },
    "inactive": {
      "bg_fill": [
        255,
        201,
        201,
        255
      ],
      "weak_bg_fill": [
        255,
        201,
        201,
        255
      ],
      "bg_stroke": {
        "width": 3.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "rounding": {
        "nw": 5.0,
        "ne": 5.0,
        "sw": 5.0,
        "se": 5.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "expansion": 0.0
    },
    "hovered": {
      "bg_fill": [
        255,
        201,
        201,
        255
      ],
      "weak_bg_fill": [
        255,
        201,
        201,
        255
      ],
      "bg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "rounding": {
        "nw": 5.0,
        "ne": 5.0,
        "sw": 5.0,
        "se": 5.0
      },
      "fg_stroke": {
        "width": 1,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "expansion": 1.0
    },
    "active": {
      "bg_fill": [
        255,
        201,
        201,
        255
      ],
      "weak_bg_fill": [
        255,
        201,
        201,
        255
      ],
      "bg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "rounding": {
        "nw": 5.0,
        "ne": 5.0,
        "sw": 5.0,
        "se": 5.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "expansion": 0.0
    },
    "open": {
      "bg_fill": [
        255,
        201,
        201,
        255
      ],
      "weak_bg_fill": [
        255,
        201,
        201,
        255
      ],
      "bg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "rounding": {
        "nw": 5.0,
        "ne": 5.0,
        "sw": 5.0,
        "se": 5.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          224,
          49,
          49,
          255
        ]
      },
      "expansion": 0.0
    }
  },
  "faint_bg_color": [
    255,
    201,
    201,
    255
  ],
  "extreme_bg_color": [
    255,
    201,
    201,
    255
  ],
  "window_fill": [
    255,
    201,
    201,
    255
  ],
  "window_highlight_topmost": true,
  "menu_rounding": {
    "nw": 6.0,
    "ne": 6.0,
    "sw": 6.0,
    "se": 6.0
  },
  "panel_fill": [
    255,
    201,
    201,
    255
  ]
}
]]

locked_biome_theme = [[
{
    "faint_bg_color": [
        5,
        5,
        5,
        0
    ],
    "extreme_bg_color": [
        10,
        10,
        10,
        255
    ],
    "code_bg_color": [
        64,
        64,
        64,
        255
    ],

  "window_fill": [
    255,
    255,
    255,
    255
  ],
  "window_stroke": {
    "width": 1.0,
    "color": [
        255,
        255,
        255,
        255
    ]
  },
  "panel_fill": [
      27,
      27,
      27,
      255
  ],
  "widgets": {
    "inactive": {
      "bg_fill": [
        248,
        249,
        250,
        255
      ],
      "weak_bg_fill": [
        248,
        249,
        250,
        255
      ],
      "bg_stroke": {
        "width": 1.0,
        "color": [
          165,
          165,
          165,
          255
        ]
      },
      "rounding": {
        "nw": 5.0,
        "ne": 5.0,
        "sw": 5.0,
        "se": 5.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          165,
          165,
          165,
          255
        ]
      },
      "expansion": 0.0
    },
    "hovered": {
      "bg_fill": [
        248,
        249,
        250,
        255
      ],
      "weak_bg_fill": [
        248,
        249,
        250,
        255
      ],
      "bg_stroke": {
        "width": 3.0,
        "color": [
          165,
          165,
          165,
          255
        ]
      },
      "rounding": {
        "nw": 6.0,
        "ne": 6.0,
        "sw": 6.0,
        "se": 6.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          165,
          165,
          165,
          255
        ]
      },
      "expansion": 0.0
    },
    "active": {
      "bg_fill": [
        248,
        249,
        250,
        255
      ],
      "weak_bg_fill": [
        248,
        249,
        250,
        255
      ],
      "bg_stroke": {
        "width": 1.0,
        "color": [
          165,
          165,
          165,
          255
        ]
      },
      "rounding": {
        "nw": 5.0,
        "ne": 5.0,
        "sw": 5.0,
        "se": 5.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          165,
          165,
          165,
          255
        ]
      },
      "expansion": 0.0
    },
    "open": {
      "bg_fill": [
        55,
        55,
        55,
        255
      ],
      "weak_bg_fill": [
        55,
        55,
        55,
        255
      ],
      "bg_stroke": {
        "width": 1.0,
        "color": [
          255,
          255,
          255,
          255
        ]
      },
      "rounding": {
        "nw": 2.0,
        "ne": 2.0,
        "sw": 2.0,
        "se": 2.0
      },
      "fg_stroke": {
        "width": 1.0,
        "color": [
          255,
          255,
          255,
          255
        ]
      },
      "expansion": 0.0
    }
  }
}
]]
land_unlock_locked_group = [[
{
  "inner_margin": {
    "left": 10.0,
    "right": 10.0,
    "top": 10.0,
    "bottom": 10.0
  },
  "outer_margin": {
    "left": 0.0,
    "right": 0.0,
    "top": 0.0,
    "bottom": 0.0
  },
  "rounding": {
    "nw": 15.0,
    "ne": 15.0,
    "sw": 15.0,
    "se": 15.0
  },
  "shadow": {
    "offset": {
      "x": 0.0,
      "y": 0.0
    },
    "blur": 0.0,
    "spread": 0.0,
    "color": [
      0,
      0,
      0,
      0
    ]
  },
  "fill": [
    233,
    236,
    239,
    255
  ],
  "stroke": {
    "width": 2.0,
    "color": [
      174,
      176,
      179,
      255
    ]
  }
}
]]
