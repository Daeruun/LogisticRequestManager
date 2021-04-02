require 'defines'

default_gui = data.raw["gui-style"].default

default_gui[lrm.defines.gui.frame] = {
    type = "frame_style",
    parent = "inner_frame_in_outer_frame",
    maximal_width = 800,
    maximal_height = 700
}

default_gui[lrm.defines.gui.title_flow] = {
    type = "horizontal_flow_style",
    horizontally_stretchable = "on",
    horizontal_spacing = 8,
    right_margin = 4
}
default_gui[lrm.defines.gui.title_frame] = {
    type = "frame_style",
    parent = "invisible_frame",
}
default_gui[lrm.defines.gui.close_button] = {
    type = "button_style",
    parent = "frame_action_button",
    -- font = "lrm.infinit",
    -- default_font_color = {255,255,255}
}

default_gui[lrm.defines.gui.save_as_textfield] = {
    type = "textbox_style",
    parent = "stretchable_textfield"
}


default_gui[lrm.defines.gui.save_as_button] = {
    type = "button_style",
    parent = "button",
    minimal_width = 40,
}

default_gui[lrm.defines.gui.blueprint_button] = {
    type = "button_style",
    parent = "slot_button",
    padding = 1,
}

default_gui[lrm.defines.gui.sidebar_button] = {
    type = "button_style",
    parent = "button",
    width = 114,
    horizontally_stretchable = "on"
}

default_gui[lrm.defines.gui.preset_list] = {
    type = "scroll_pane_style",
    parent = "scroll_pane",
    width = 150,
    vertically_stretchable = "on",
    horizontally_stretchable = "on"
}

default_gui[lrm.defines.gui.preset_button] = {
    type = "button_style",
    parent = "button",
    horizontally_stretchable = "on",
    horizontally_squashable = "on"
}

default_gui[lrm.defines.gui.preset_button_selected] = {
    type = "button_style",
    parent = lrm.defines.gui.preset_button,
    default_graphical_set = {base = {position = {34, 17}, corner_size = 8}},
    hovered_graphical_set = {base = {position = {34, 17}, corner_size = 8}},
    clicked_graphical_set = {base = {position = {34, 17}, corner_size = 8}},
}

default_gui[lrm.defines.gui.request_window] = {
    type = "scroll_pane_style",
    parent = "scroll_pane",
    width = 420,
    heigth = 208,
    minimal_height = 208,
    maximal_height = 208,
    margin = 0,
    padding = 0,
    vertical_align = "bottom",
    vertically_squashable = "off"
}

default_gui[lrm.defines.gui.request_table] = {
    type = "table_style",
    parent = "table",
    vertical_spacing = 0,
    horizontal_spacing = 0,
    minimal_heigth = 200,
    padding = 0
}

default_gui[lrm.defines.gui.request_slot] = {
    type = "button_style",
    parent = "slot_button"
}

default_gui[lrm.defines.gui.request_count] = {
    type = "label_style",
    parent = "count_label",
    width = 36,
    height = 36,
    left_padding = -4,
    right_padding = 4,
    horizontal_align = "right",
    vertical_align = "bottom"
}

data:extend(
  {
    {
      type = "font",
      name = "lrm.infinit",
      from = "default-bold",
      size = 20
    }
  }
)

default_gui[lrm.defines.gui.request_infinit] = {
    type = "label_style",
    parent = "count_label",
    font = "lrm.infinit",
    width = 36,
    height = 36,
    left_padding = -5,
    right_padding = 5,
    bottom_padding = -4,
    horizontal_align = "right",
    vertical_align = "bottom"
}

default_gui[lrm.defines.gui.export_frame] = {
    type = "frame_style",
    parent = "inner_frame_in_outer_frame",
    direction = "vertical",
    width = 424,
    heigth = 338,
    vertically_stretchable = "on",
}

default_gui[lrm.defines.gui.code_textbox] = {
     type = "textbox_style",
     minimal_width = 420,
     minimal_height = 250,
     maximal_width = 420,
     maximal_height = 250,
}

default_gui[lrm.defines.gui.import_frame] = {
    type = "frame_style",
    parent = "inner_frame_in_outer_frame",
    direction = "vertical",
    width = 424,
    heigth = 338,
    vertically_stretchable = "on",
}
default_gui[lrm.defines.gui.import_preview_frame] = { 
    type = "frame_style",
    parent = "inner_frame_in_outer_frame",
    direction = "vertical",
    minimal_width = 424,
    minimal_heigth = 30,
    vertically_stretchable = "on",
}
