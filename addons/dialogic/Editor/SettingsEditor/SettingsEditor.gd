tool
extends ScrollContainer

var editor_reference

onready var nodes = {
	'themes': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer/HBoxContainer/ThemeOptionButton,
	'advanced_themes': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer/HBoxContainer2/AdvancedThemes,
	'translations': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer6/Translations,
	'new_lines': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer2/NewLines,
	'remove_empty_messages': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer/RemoveEmptyMessages,
	'auto_color_names': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer3/AutoColorNames,
	'propagate_input': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer4/PropagateInput,
	'dim_characters': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer5/DimCharacters,
	'text_event_audio_enable': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer7/EnableVoices,
	'text_event_audio_default_bus' : $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/TextAudioDefaultBus/AudioBus,
	'save_current_timeline': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer/SaveCurrentTimeline,
	'clear_current_timeline': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer2/ClearCurrentTimeline,
	'save_definitions_on_start': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer3/SaveDefinitionsOnStart,
	'save_definitions_on_end': $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer4/SaveDefinitionsOnEnd,
	'delay_after_options': $VBoxContainer/HBoxContainer3/VBoxContainer2/VBoxContainer/HBoxContainer/LineEdit,
	'default_action_key': $VBoxContainer/HBoxContainer3/VBoxContainer2/VBoxContainer/HBoxContainer2/DefaultActionKey,
	'canvas_layer' : $VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer/HBoxContainer3/CanvasLayer}

	#'use_custom_events':$VBoxContainer/HBoxContainer3/VBoxContainer2/TimelineSection/CustomEvents/CustomEvents}

var THEME_KEYS := [
	'advanced_themes',
	'canvas_layer',
	]

var INPUT_KEYS := [
	'delay_after_options',
	'default_action_key'
	]

var DIALOG_KEYS := [
	'translations',
	'new_lines', 
	'remove_empty_messages',
	'auto_color_names',
	'propagate_input',
	'dim_characters',
	'text_event_audio_enable',
	]

var SAVING_KEYS := [
	'save_current_timeline', 
	'clear_current_timeline',
	'save_definitions_on_start',
	'save_definitions_on_end',
	]

func _ready():
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer/HBoxContainer/Label".text = DTS.translate("Default")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer/HBoxContainer2/Label".text = DTS.translate("Advanced theme options")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer/HBoxContainer3/Label".text = DTS.translate("Canvas layer :")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer2/Label".text = DTS.translate("New lines will create extra messages")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer/Label".text = DTS.translate("Remove empty messages")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer3/Label".text = DTS.translate("Auto color character names in messages")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer4/Label".text = DTS.translate("Propagate input to rest of the Tree")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer5/Label".text = DTS.translate("Dim characters when they are not speaking")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/Label3".text = DTS.translate("Audio for Text events:")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer7/Label".text = DTS.translate("Enable audio for Text events")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/TextAudioDefaultBus/Label".text = DTS.translate("Default bus for Text event audio")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/Label2".text = DTS.translate("Experimental Translations:")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer2/HBoxContainer6/Label".text = DTS.translate("Inputs for text events will be treated as keys for tr()")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer/Label".text = DTS.translate("Save current timeline on timeline start")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer2/Label".text = DTS.translate("Clear saved timeline on timeline end")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer3/Label".text = DTS.translate("Save definitions on timeline start")
	$"VBoxContainer/HBoxContainer3/VBoxContainer/VBoxContainer3/HBoxContainer4/Label".text = DTS.translate("Save definitions on timeline end")
	$"VBoxContainer/HBoxContainer3/VBoxContainer2/VBoxContainer/HBoxContainer/Label".text = DTS.translate("Enable choice options after  ")
	$"VBoxContainer/HBoxContainer3/VBoxContainer2/VBoxContainer/HBoxContainer/Label2".text = DTS.translate(" seconds")
	$"VBoxContainer/HBoxContainer3/VBoxContainer2/VBoxContainer/HBoxContainer2/Label".text = DTS.translate("Default action key")
	
	editor_reference = find_parent('EditorView')
	update_bus_selector()
	
	update_data()
	
	# Themes
	nodes['themes'].connect('item_selected', self, '_on_default_theme_selected')
	nodes['delay_after_options'].connect('text_changed', self, '_on_delay_options_text_changed')
	# TODO move to theme section later
	nodes['advanced_themes'].connect('toggled', self, '_on_item_toggled', ['dialog', 'advanced_themes'])
	nodes['canvas_layer'].connect('text_changed', self, '_on_canvas_layer_text_changed')

	nodes['default_action_key'].connect('pressed', self, '_on_default_action_key_presssed')
	nodes['default_action_key'].connect('item_selected', self, '_on_default_action_key_item_selected')
	
	AudioServer.connect("bus_layout_changed", self, "update_bus_selector")
	nodes['text_event_audio_default_bus'].connect('item_selected', self, '_on_text_audio_default_bus_item_selected')
	
	for k in DIALOG_KEYS:
		nodes[k].connect('toggled', self, '_on_item_toggled', ['dialog', k])
	
	for k in SAVING_KEYS:
		nodes[k].connect('toggled', self, '_on_item_toggled', ['saving', k])

func update_data():
	var settings = DialogicResources.get_settings_config()
	nodes['canvas_layer'].text = settings.get_value("theme", "canvas_layer", '1')
	refresh_themes(settings)
	load_values(settings, "dialog", DIALOG_KEYS)
	load_values(settings, "saving", SAVING_KEYS)
	load_values(settings, "input", INPUT_KEYS)
	select_bus(settings.get_value("dialog", 'text_event_audio_default_bus', "Master"))

func load_values(settings: ConfigFile, section: String, key: Array):
	for k in key:
		if settings.has_section_key(section, k):
			if nodes[k] is LineEdit:
				nodes[k].text = settings.get_value(section, k)
			else:
				if k == 'default_action_key':
					nodes['default_action_key'].text = settings.get_value(section, k)
				else:
					nodes[k].pressed = settings.get_value(section, k, false)


func refresh_themes(settings: ConfigFile):
	# TODO move to theme section later
	if settings.has_section_key('dialog', 'advanced_themes'):
		nodes['advanced_themes'].pressed = settings.get_value('dialog', 'advanced_themes')
	
	nodes['themes'].clear()
	var theme_list = DialogicUtil.get_sorted_theme_list()
	var theme_indexes = {}
	var index = 0
	for theme in theme_list:
		nodes['themes'].add_item(theme['name'])
		nodes['themes'].set_item_metadata(index, {'file': theme['file']})
		theme_indexes[theme['file']] = index
		index += 1
	
	# Only one item added, then save as default
	if index == 1: 
		set_value('theme', 'default', theme_list[0]['file'])
	
	# More than one theme? Select which the default one is
	if index > 1:
		if settings.has_section_key('theme', 'default'):
			nodes['themes'].select(theme_indexes[settings.get_value('theme', 'default', null)])
		else:
			# Fallback
			set_value('theme', 'default', theme_list[0]['file'])


func _on_default_theme_selected(index):
	set_value('theme', 'default', nodes['themes'].get_item_metadata(index)['file'])


func _on_delay_options_text_changed(text):
	set_value('input', 'delay_after_options', text)


func _on_item_toggled(value: bool, section: String, key: String):
	set_value(section, key, value)


func _on_default_action_key_presssed() -> void:
	var settings = DialogicResources.get_settings_config()
	nodes['default_action_key'].clear()
	nodes['default_action_key'].add_item(settings.get_value('input', 'default_action_key', '[Default]'))
	nodes['default_action_key'].add_item('[Default]')
	InputMap.load_from_globals()
	for a in InputMap.get_actions():
		nodes['default_action_key'].add_item(a)


func _on_default_action_key_item_selected(index) -> void:
	set_value('input', 'default_action_key', nodes['default_action_key'].text)


func _on_canvas_layer_text_changed(text) -> void:
	set_value('theme', 'canvas_layer', text)


# Reading and saving data to the settings file
func set_value(section, key, value):
	DialogicResources.set_settings_value(section, key, value)

func update_bus_selector():
	if nodes["text_event_audio_default_bus"] != null:
		var previous_selected_bus_name = ""
		if nodes["text_event_audio_default_bus"].get_item_count():
			previous_selected_bus_name = nodes["text_event_audio_default_bus"].get_item_text(max(0, nodes["text_event_audio_default_bus"].selected))

		nodes["text_event_audio_default_bus"].clear()
		for i in range(AudioServer.bus_count):
			var bus_name = AudioServer.get_bus_name(i)
			nodes["text_event_audio_default_bus"].add_item(bus_name)

			if previous_selected_bus_name == bus_name:
				nodes["text_event_audio_default_bus"].select(i)


func select_bus(text):
	for item_idx in range(nodes["text_event_audio_default_bus"].get_item_count()):
		if nodes["text_event_audio_default_bus"].get_item_text(item_idx) == text:
			nodes["text_event_audio_default_bus"].select(item_idx)
			return
	nodes["text_event_audio_default_bus"].select(0)


func _on_text_audio_default_bus_item_selected(index):
	var text = nodes['text_event_audio_default_bus'].get_item_text(index)
	set_value('dialog', 'text_event_audio_default_bus', text)


func _on_CustomEventsFolder_pressed():
	editor_reference.godot_dialog("", EditorFileDialog.MODE_OPEN_DIR)
	editor_reference.godot_dialog_connect(self, "_on_CustomEventsFolder_selected", "dir_selected")
	#editor_reference.godot_dialog_connect(self, "_on_CustomEventsFolder_selected", "file_selected")

func _on_CustomEventsFolder_selected(path, target):
	DialogicResources.set_settings_value("editor", 'custom_events_path', path)
	nodes['custom_events_folder_button'].text = DialogicResources.get_filename_from_path(path)
	editor_reference.get_node("MainPanel/TimelineEditor").update_custom_events()



func _on_RefreshCustomEvents_pressed():
	editor_reference.get_node("MainPanel/TimelineEditor").update_custom_events()
