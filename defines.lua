if not lrm then lrm = {} end 
if not lrm.defines then lrm.defines = {} end

lrm.defines.preset_string_version=2
lrm.defines.protected_presets=10

lrm.defines.id        = "logistic-request-manager"
lrm.defines.guiprefix = lrm.defines.id .. "-gui-"

lrm.defines.gui = {
	toggle_button               = lrm.defines.guiprefix .. "button",

	master                      = lrm.defines.guiprefix .. "master",
	frame                       = lrm.defines.guiprefix .. "frame",
	flow                        = lrm.defines.guiprefix .. "flow",
	
	title_flow                  = lrm.defines.guiprefix .. "title_flow",
	title_frame                 = lrm.defines.guiprefix .. "title_frame",
	close_button                = lrm.defines.guiprefix .. "close_button",
	test_button                 = lrm.defines.guiprefix .. "test_button",

	toolbar                     = lrm.defines.guiprefix .. "toolbar",
	save_as_textfield           = lrm.defines.guiprefix .. "save-as-input",
	save_as_button              = lrm.defines.guiprefix .. "save-as-button",
	blueprint_button            = lrm.defines.guiprefix .. "blueprint-request",
	
	body                        = lrm.defines.guiprefix .. "body",
	body_right                  = lrm.defines.guiprefix .. "body_right",
	
	sidebar                     = lrm.defines.guiprefix .. "sidebar",
	sidebar_button              = lrm.defines.guiprefix .. "sidebar-button",
	save_button                 = lrm.defines.guiprefix .. "save-button",
	load_button                 = lrm.defines.guiprefix .. "load-button",
	delete_button               = lrm.defines.guiprefix .. "delete-button",
	export_button               = lrm.defines.guiprefix .. "export-button",
	import_button               = lrm.defines.guiprefix .. "import-button",
	
	target_menu                 = lrm.defines.guiprefix .. "target-menu",
	target_label                = lrm.defines.guiprefix .. "target-label",
	target_slot                 = lrm.defines.guiprefix .. "target-slot",
	
	preset_list                 = lrm.defines.guiprefix .. "preset-list",
	preset_button               = lrm.defines.guiprefix .. "preset-button",
	preset_button_selected      = lrm.defines.guiprefix .. "preset-button-selected",
	
	request_window              = lrm.defines.guiprefix .. "request-window",
	request_table               = lrm.defines.guiprefix .. "request-table",
	request_slot                = lrm.defines.guiprefix .. "request-slot",
	request_count               = lrm.defines.guiprefix .. "request-count",
	request_min                 = lrm.defines.guiprefix .. "request-min",
	request_max                 = lrm.defines.guiprefix .. "request-max",
	request_infinit             = lrm.defines.guiprefix .. "request-infinit",

	export_frame                = lrm.defines.guiprefix .. "export-frame",
	import_frame                = lrm.defines.guiprefix .. "import-frame",

	code_textbox                = lrm.defines.guiprefix .. "code-textbox",
	import_textfield            = lrm.defines.guiprefix .. "import-textfield",

	OK_button                   = lrm.defines.guiprefix .. "OK-button",
	copy_button                 = lrm.defines.guiprefix .. "copy-button",
	empty                       = lrm.defines.guiprefix .. "empty",

	import_preview_frame        = lrm.defines.guiprefix .. "import-preview-frame",
	import_preview_toolbar      = lrm.defines.guiprefix .. "import-preview-toolbar",
	save_import_as_textfield    = lrm.defines.guiprefix .. "save-import-as-textfield",
	save_import_as_button       = lrm.defines.guiprefix .. "save-import-as-button",
}