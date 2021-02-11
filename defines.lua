if not lrm then lrm = {} end

lrm.id = "logistic-request-manager"
lrm.guiprefix = lrm.id .. "-gui-"

lrm.gui = {
	toggle_button =     lrm.guiprefix .. "button",

	master =            lrm.guiprefix .. "master",
	frame =             lrm.guiprefix .. "frame",
	flow =              lrm.guiprefix .. "flow",
	
	title_flow =        lrm.guiprefix .. "title_flow",
	title_frame =		lrm.guiprefix .. "title_frame",
	close_button =  	lrm.guiprefix .. "close_button",
	test_button =  	lrm.guiprefix .. "test_button",

	toolbar =           lrm.guiprefix .. "toolbar",
	save_as_textfield = lrm.guiprefix .. "save-as-input",
	save_as_button =    lrm.guiprefix .. "save-as-button",
	blueprint_button =  lrm.guiprefix .. "blueprint-request",
	
	body =              lrm.guiprefix .. "body",
	body_right =        lrm.guiprefix .. "body_right",
	
	sidebar =           lrm.guiprefix .. "sidebar",
	sidebar_button =    lrm.guiprefix .. "sidebar-button",
	save_button =       lrm.guiprefix .. "save-button",
	load_button =       lrm.guiprefix .. "load-button",
	delete_button =     lrm.guiprefix .. "delete-button",
	export_button =     lrm.guiprefix .. "export-button",
	import_button =     lrm.guiprefix .. "import-button",
	
	target_menu =       lrm.guiprefix .. "target-menu",
	target_label =      lrm.guiprefix .. "target-label",
	target_slot =       lrm.guiprefix .. "target-slot",
	
	preset_list =       lrm.guiprefix .. "preset-list",
	preset_button =     lrm.guiprefix .. "preset-button",
	preset_button_selected = lrm.guiprefix .. "preset-button-selected",
	
	request_window =    lrm.guiprefix .. "request-window",
	request_table =     lrm.guiprefix .. "request-table",
	request_slot =      lrm.guiprefix .. "request-slot",
	request_min = 		lrm.guiprefix .. "request-min",
	request_max = 	    lrm.guiprefix .. "request-max",
	request_infinit =   lrm.guiprefix .. "request-infinit",

	export_frame =		lrm.guiprefix .. "export-frame",
	import_frame =		lrm.guiprefix .. "import-frame",

	code_textbox =		lrm.guiprefix .. "code-textbox",
	import_textfield =	lrm.guiprefix .. "import-textfield",

	OK_button 	=		lrm.guiprefix .. "OK-button",
	copy_button =		lrm.guiprefix .. "copy-button",
	empty		=		lrm.guiprefix .. "empty",

	import_preview_frame    	= lrm.guiprefix .. "import-preview-frame",
	import_preview_toolbar		= lrm.guiprefix .. "import-preview-toolbar",
	save_import_as_textfield	= lrm.guiprefix .. "save-import-as-textfield",
	save_import_as_button		= lrm.guiprefix .. "save-import-as-button",
	
}