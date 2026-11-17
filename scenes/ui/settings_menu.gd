class_name SettingsMenu
extends Control

var _rebinding_action: StringName = &""
var _rebind_button: Button


func _ready() -> void:
	_ensure_action(&"move_left", KEY_A)
	_ensure_action(&"move_right", KEY_D)
	_ensure_action(&"jump", KEY_SPACE)

	$CenterContainer/Panel/Margin/Content/Tabs/Display/ResolutionOption.add_item("1280 x 720")
	$CenterContainer/Panel/Margin/Content/Tabs/Display/ResolutionOption.add_item("1600 x 900")
	$CenterContainer/Panel/Margin/Content/Tabs/Display/ResolutionOption.item_selected.connect(_on_resolution_selected)
	$CenterContainer/Panel/Margin/Content/Tabs/Display/FullscreenCheck.toggled.connect(_on_fullscreen_toggled)
	$CenterContainer/Panel/Margin/Content/Tabs/Audio/MasterVolumeSlider.value_changed.connect(_on_master_volume_changed)
	$CenterContainer/Panel/Margin/Content/Tabs/Audio/MuteCheck.toggled.connect(_on_mute_toggled)
	$CenterContainer/Panel/Margin/Content/Tabs/Controls/MoveLeftButton.pressed.connect(_begin_rebind.bind(&"move_left"))
	$CenterContainer/Panel/Margin/Content/Tabs/Controls/MoveRightButton.pressed.connect(_begin_rebind.bind(&"move_right"))
	$CenterContainer/Panel/Margin/Content/Tabs/Controls/JumpButton.pressed.connect(_begin_rebind.bind(&"jump"))
	$CenterContainer/Panel/Margin/Content/BackButton.pressed.connect(_on_back_pressed)
	_update_rebind_button_labels()


func _input(event: InputEvent) -> void:
	if _rebinding_action.is_empty() or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		_finish_rebind()
		return
	apply_rebind(_rebinding_action, event as InputEventKey)


func begin_rebind(action: StringName) -> void:
	_begin_rebind(action)


func apply_rebind(action: StringName, event: InputEventKey) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_finish_rebind()
	_update_rebind_button_labels()


func _begin_rebind(action: StringName) -> void:
	_rebinding_action = action
	_rebind_button = _button_for_action(action)
	if is_instance_valid(_rebind_button):
		_rebind_button.text = "Press a key..."


func _finish_rebind() -> void:
	_rebinding_action = &""
	_rebind_button = null


func _ensure_action(action: StringName, default_key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if InputMap.action_get_events(action).is_empty():
		var event := InputEventKey.new()
		event.physical_keycode = default_key
		InputMap.action_add_event(action, event)


func _button_for_action(action: StringName) -> Button:
	match action:
		&"move_left": return $CenterContainer/Panel/Margin/Content/Tabs/Controls/MoveLeftButton as Button
		&"move_right": return $CenterContainer/Panel/Margin/Content/Tabs/Controls/MoveRightButton as Button
		&"jump": return $CenterContainer/Panel/Margin/Content/Tabs/Controls/JumpButton as Button
	return null


func _update_rebind_button_labels() -> void:
	for action in [&"move_left", &"move_right", &"jump"]:
		var button := _button_for_action(action)
		var key_name := "Unbound"
		var events := InputMap.action_get_events(action)
		if not events.is_empty() and events[0] is InputEventKey:
			var key_event := events[0] as InputEventKey
			key_name = OS.get_keycode_string(key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode)
		button.text = "%s: %s" % [String(action).capitalize().replace("_", " "), key_name]


func _on_resolution_selected(index: int) -> void:
	var sizes := [Vector2i(1280, 720), Vector2i(1600, 900)]
	DisplayServer.window_set_size(sizes[index])


func _on_fullscreen_toggled(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func _on_master_volume_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.001)))


func _on_mute_toggled(muted: bool) -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, muted)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/game_ui.tscn")
