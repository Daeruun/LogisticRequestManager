require 'defines'

data:extend({
    {
        type = "double-setting",
        name = "LogisticRequestManager-display_slots_by_tick_ratio",
        order = "zy",
        setting_type = "runtime-per-user",
        allowed_values ={0,0.1,0.2,0.3,0.5,1,2,3,4,5,6,7,8,9,10,15,20,25,50},
        default_value = 10
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-display_slots_warning",
        order = "zz",
        setting_type = "runtime-per-user",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-default_to_user",
        order = "aaaa",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-allow_gui_without_research",
        order = "aaab",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-create_preset-autotrash",
        order = "aaac",
        setting_type = "runtime-per-user",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-allow_constant_combinator",
        order = "aab",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-appended_requests_after_existing_ones",
        order = "aab",
        setting_type = "runtime-per-user",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-always_append_blueprints",
        order = "aac",
        setting_type = "runtime-per-user",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "LogisticRequestManager-blueprint_item_requests_unlimited",
        order = "aac",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "string-setting",
        name = "LogisticRequestManager-enable-append",
        order = "aba",
        setting_type = "runtime-per-user",
        default_value = "on_modifier",
        allowed_values = {"never", "always", "on_modifier", "not_on_modifier"}
    },
    {
        type = "string-setting",
        name = "LogisticRequestManager-enable-undefined_max_as_infinit",
        order = "abb",
        setting_type = "runtime-per-user",
        default_value = "on_modifier",
        allowed_values = {"never", "always", "on_modifier", "not_on_modifier"}
    },
    {
        type = "string-setting",
        name = "LogisticRequestManager-enable-round_up",
        order = "abc",
        setting_type = "runtime-per-user",
        default_value = "on_modifier",
        allowed_values = {"never", "always", "on_modifier", "not_on_modifier"}
    },
    {
        type = "string-setting",
        name = "LogisticRequestManager-modifier-append",
        order = "aba",
        setting_type = "runtime-per-user",
        default_value = "SHIFT",
        allowed_values = {"CTRL", "SHIFT", "ALT", "CTRL+SHIFT", "CTRL+ALT", "SHIFT+ALT", "CTRL+SHIFT+ALT"}
    },
    {
        type = "string-setting",
        name = "LogisticRequestManager-modifier-undefined_max_as_infinit",
        order = "abb",
        setting_type = "runtime-per-user",
        default_value = "ALT",
        allowed_values = {"CTRL", "SHIFT", "ALT", "CTRL+SHIFT", "CTRL+ALT", "SHIFT+ALT", "CTRL+SHIFT+ALT"}
    },
    {
        type = "string-setting",
        name = "LogisticRequestManager-modifier-round_up",
        order = "abc",
        setting_type = "runtime-per-user",
        default_value = "CTRL",
        allowed_values = {"CTRL", "SHIFT", "ALT", "CTRL+SHIFT", "CTRL+ALT", "SHIFT+ALT", "CTRL+SHIFT+ALT"}
    },
})