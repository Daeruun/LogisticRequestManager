require 'defines'

require 'prototypes/style'


local button_toggle={
    type = "custom-input",
    name = "LRM-input-toggle-gui",
    key_sequence = "SHIFT + L",
    consuming = "none"
}
data:extend{button_toggle}

data:extend(
{
    {
        type = "sprite",
        name = "LRM-paste",
        filename = "__base__/graphics/icons/shortcut-toolbar/mip/paste-x24.png",
        priority = "extra-high-no-scale",
        width = 24,
        height = 24,
        flags = {"gui-icon"},
        mipmap_count = 2,
        scale = 0.5
      },
      {
        type = "sprite",
        name = "LRM-copy",
        filename = "__base__/graphics/icons/shortcut-toolbar/mip/copy-x24.png",
        priority = "extra-high-no-scale",
        width = 24,
        height = 24,
        flags = {"gui-icon"},
        mipmap_count = 2,
        scale = 0.5
      },

      -- dummy item for removed items
      {
          type = "item",
          name = "LRM-dummy-item",
          icon = "__core__/graphics/cancel.png",
          icon_size = 64,
          flags = {"hidden", "not-stackable"},
          subgroup = "other",
          stack_size = 1          
      }
})