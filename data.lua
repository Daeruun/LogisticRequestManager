require 'defines'

require 'prototypes/style'

data:extend(
{
  {
    type = "custom-input",
    name = "LRM-input-toggle-gui",
    key_sequence = "SHIFT + L",
    consuming = "none"
  },
  {
    type = "custom-input",
    name = "LRM-input-close-gui",
    key_sequence = "",
    linked_game_control = "toggle-menu",
    consuming = "none"
  }
})

data:extend(
{
    {
      type = "sprite",
      name = "LRM-preset-arrow-down",
      filename = "__LogisticRequestManager__/icons/arrow-down-x48.png",
      priority = "extra-high-no-scale",
      width = 48,
      height = 48,
      flags = {"gui-icon"},
      mipmap_count = 1
    },
    {
      type = "sprite",
      name = "LRM-preset-arrow-up",
      filename = "__LogisticRequestManager__/icons/arrow-up-x48.png",
      priority = "extra-high-no-scale",
      width = 48,
      height = 48,
      flags = {"gui-icon"},
      mipmap_count = 1
    },
    {
        type = "sprite",
        name = "LRM-apply",
        filename = "__LogisticRequestManager__/icons/apply-personal-logistics-x32.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        flags = {"gui-icon"},
        mipmap_count = 2,
        scale = 0.5
      },
      {
        type = "sprite",
        name = "LRM-save",
        filename = "__LogisticRequestManager__/icons/save-x48.png",
        priority = "extra-high-no-scale",
        width = 48,
        height = 48,
        flags = {"gui-icon"},
        mipmap_count = 1,
        -- scale = 0.5
      },
      {
        type = "sprite",
        name = "LRM-save-as",
        filename = "__LogisticRequestManager__/icons/save-as-x48.png",
        priority = "extra-high-no-scale",
        width = 48,
        height = 48,
        flags = {"gui-icon"},
        mipmap_count = 1,
        -- scale = 0.5
      },

      {
        type = "sprite",
        name = "LRM-autotrash",
        layers = {
          {
            filename = "__core__/graphics/icons/mip/trash.png",
            width = 32,
            height = 32,
            shift = {-4, 4},
            -- draw_as_shadow = true,
          },
          {
            filename = "__core__/graphics/icons/mip/refresh.png",
            width = 32,
            height = 32,
            shift = {4, -4},
            scale = 1.2,
          },
        },
        flags = {"gui-icon"},
        mipmap_count = 1,
      },
      -- dummy item for removed items
      {
          type = "item",
          name = "LRM-dummy-item",
          icon = "__core__/graphics/cancel.png",
          icon_size = 64,
          stack_size = 1,
          flags = {"hidden"},
          subgroup = "other",
      }
})

require 'prototypes/shortcuts'
