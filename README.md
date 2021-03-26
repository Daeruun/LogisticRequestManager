# LogisticRequestManager
A factorio mod for managing logistic request presets.

# Original Mod by Goalie: [Logistic-Request-Manager](https://mods.factorio.com/mod/Logistic-Request-Manager) 
I was asked to re-upload the mod with my fixes for the original mod to have the download available ingame, so here it is.
**Credits and my thanks go to Goalie for the original mod!**

# What does it do? 
The mod offers the possibility to save or load presets of logistic requests.
It is also possible to request all items required to build a given blueprint.
Saved presets can be exported as strings (similar to blueprints) and exchanged or re-imported.
This function is compatible with serveral other mods, for example [Personal Logistics Import/Export](https://mods.factorio.com/mod/PersonalLogisticsImportExport)

Access to the GUI is available via the logistic bot icon in the top-left of the screen or a short-cut, once personal logistics is researched:

![this icon in the topleft corner opens the GUI](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/LRM_toggle_button.png?raw=true)

## Version 0.18.x only 
- Requests to chests can only contain 30 different item-types. 
Therefor presets that contain more than 30 different item-types will be rejected.
If the limit is not exceeded, but the requests are spread out over more than the first 30 slots all empty slots will be ignored and the requests will be squished together.

## Version 1.1.x only
- Vehicles as the spidertron can be used in the same way as the player-character.



# Configuration
A few things can be configured:

## user-specific settings:
### character as default target
![mod settings - per player - charcter as default](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/mod_settings.png?raw=true)  
This setting allows to interact with the character when no other entity that supports logistic requests is open. It can be changed anytime.

### always add requests from blueprints to existing requests
![mod settings - per player - always add blueprints](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/mod_settings_add_blueprints.png?raw=true)  
If this setting is enabled blueprints will not overwrite existing requests regardless of the corresponding modifier settings below.

### create unlimited requests from blueprints
![mod settings - per player - infinite blueprint requests](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/mod_settings_infinte_blueprint_requests.png?raw=true)  
If this is enabled, blueprint requets will be created with an unlimited request if added to player or vehicles as the spidertron.
Otherwise the modifier-setting for unlimited chets below will be used.

### modifier to add requests to existing requets
![mod settings - per player - add presets to requests](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/mod_settings_modifier_add_requests.png?raw=true)  
This setting allows to add new requests to existing ones instead of overwriting them.

### modifier to save requests from chests with unlimited max
![mod settings - per player - unlimited chest requests](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/mod_settings_modifier_unlimited_chest_requests.png?raw=true)  
By default requests from entities with only one setting for requests will be limited to that value. This modifier allows to change this limit to infinity.

### modifier to round up requests to their stacksize
![mod settings - per player - unlimited chest requests](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/mod_settings_modifier_round_up_requests_to_stacksize.png?raw=true)  
This modifier allows to round up requests to their stacksize. If the request happens to be configured at a multiple of its stacksize it is not changed.

## user-control / hot-keys:
### toggle the GUI:
![controls - mods - Toggle Logitic Request Manager GUI](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/controls_settings.png?raw=true)
This shortcut opens or closes the whole GUI.

### close the GUI:
This one is linked to the 'toggle-menu' hotkey and cannot be changed.

# How to
For this How-To it is assumed that the player-character is NOT configured as default-target.
In each part of the How-To another entity is used as interaction target (character, requester & buffer chest, spidertron). All these interactions can be done with each of these entities - as far as available in-game.

## First time opening the GUI and creating the first preset:
- Once you open the GUI for the first time, all you will see is a frame with some buttons, and an two presets you can select.  
The `empty` preset will simply remove all requests from the target, the `auto-trash`-preset configures requests with an auto-trash limit of zero for every normal item in the game but such with an inventory (armors, spidertron and such). Those will not be auto-trashed at all.
- Depending on whether an entity that supports logistic requests is opened, or the player-character is configured as default target* some buttons may be disabled or not.
- The current target for interactions with the GUI is shown in the bottom-middle of the frame.
- Now open the player-character and configure some requests that you want to reuse.
- Enter a suitable name into the textbox.
- Click onto the button next to the textbox - the one with the disk-with-pen icon to save the requests as a new preset.
- The new preset is displayed in the GUI.

![01_save_a_first_preset](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/01_save_a_first_preset.gif?raw=true)

## To export a preset as encoded string
- Have the mods GUI open.
- Chose the preset to export.
- Click the button with the arrow pointing out of the basket.
- A new part of the GUI opens. 
- Copy the string from that textbox and save it somewhere or give it to a friend.

![02_export_a_preset](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/02_export_a_preset.gif?raw=true)

## To import a preset from an encoded string
- Have the mods GUI open.
- Chose the preset to export.
- Click the button with the arrow pointing into the basket.
- A new part of the GUI opens. 
- Copy your encoded string into the textbox and klick the OK-button.
- The right frame changes to a preview of the preset in the imported string.
- **NOTE:** If the imported preset contains requests for items that are not present in the game due to missing mods or some other reason, these items are replaced by a dummy (red X in the gif) in the GUI. They will be ignored when applying a preset until the mod they originated in is loaded.
- If the string originated in an LRM-export, the name under which the preset was saved before exporting is put into the textbox.
- Change the name to your liking and finally hit the button with the disk-with-pen right next to the textbox.
- The preview-frame is closed.
- The new preset is displayed in the main part of the GUI.

![03_import_a_preset](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/03_import_a_preset.gif?raw=true)

## To load a preset (into a chest and create a new preset from there):
- Have the mods gui open.
- Choose an existing preset.
- Open a chest (buffer-chest in this example), or another requester-entity.
- Click the green button in the bottom-right corner (the one with the upward arrow and a logistic bot pictogram) to apply the preset.
- The preset is loaded into the chest.  
**In Factorio <= 1.0.0 chests have a fixed maximum of 30 items to request, constant combinators are limited to 18 signals, in Factorio 1.1.x. constant combinators can hold 20 signals**
Presets with more slots, that do not contain more than items/signals as supported are squished together to fit. Presets containing more than that will not be applied and an error-message will be printed.
- **NOTE:** Items/signals that are not available (marked as red X in the gui) CANNOT be configured into the target.
- If you now create a new preset, potentially missing items are NOT part of the new preset any more!
![04_apply_and_create_a_preset_to_or_from_chest](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/04_apply_and_create_a_preset_to_or_from_chest.gif?raw=true)

## To request the content of a blueprint (into spidertron):
- Have the mods GUI open.
- Open the spidertron, or another requester-entity to update.
- Pick a blueprint(book) with the mouse.
- Put the blueprint onto the blueprint icon in the top-right corner of the mods GUI 
**In Factorio <= 1.0.0 chests have a fixed maximum of 30 items to request.**
Blueprint(books) containing more than 40 items will not be applied and an error-message will be printed. Same rule applies if the sum of already present requests and items in the blueprint exceeds the maximum.
- Save the new configuration if required.
![05_request_a_blueprint_into_spidertron](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/05_request_a_blueprint_into_spidertron.gif?raw=true)

## To modify or overwrite a preset:
- Have the mods GUI open.
- Select the preset to modify.
- Default-presets cannot be overwritten.
- Open the player-character or another requester-entity.
- Configure your request(s) in the open entity.
- Save the preset by clicking the button with the disk-icon in the mods GUI.
**There is no undo function for this.**
![06_modify_a_preset](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/06_modify_a_preset.gif?raw=true)

## To delete a preset
- Have the mods GUI open.
- Select the preset to delete.
- Delete the preset by clicking the red button with the trash-bin.
**There is no undo function for this.**
![07_delete_a_preset](https://github.com/Daeruun/LogisticRequestManager/blob/master/man/07_delete_a_preset.gif?raw=true)

## Commands
At the moment one command with two valid parameters exists.
It can be used to re-create the default templates after they were deleted or if the auto-trash-preset needs to be updated (if a mod added new items for example).
Usage:  
`/lrm [parameter]` with one of these parameters: `help, force_gui, inject_empty, inject_autotrash`

# Known bugs
- Blueprints that are stored in the library cannot be imported correctly due to limitations in the factorio-api.
Workaround: 
Copy(!) the blueprint/book into the player-inventory and import it from here.

# To Do
- ~~Possibly enable editing requests in the mod.~~ (I see no real reason to do this)

# Feedback
Feel free to report bugs or other feedback in the discussion tab or via [GitHub Issues](https://github.com/Daeruun/LogisticRequestManager/issues).