# GdUnit4 tests for the basic game title screen.
class_name GameUITest
extends GdUnitTestSuite

const GAME_UI_SCENE: PackedScene = preload("res://scenes/ui/game_ui.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")

func test_title_screen_has_expected_title() -> void:
	var ui := GAME_UI_SCENE.instantiate()
	add_child(ui)

	var title: Label = ui.get_node("CenterContainer/Menu/Title")
	assert_str(title.text).is_equal("Natural Selection")

	ui.queue_free()


func test_title_screen_shows_start_and_quit_buttons() -> void:
	var ui := GAME_UI_SCENE.instantiate()
	add_child(ui)

	var start_button: Button = ui.get_node("CenterContainer/Menu/StartButton")
	var settings_button: Button = ui.get_node("CenterContainer/Menu/SettingsButton")
	var quit_button: Button = ui.get_node("CenterContainer/Menu/QuitButton")
	assert_bool(start_button.visible).is_true()
	assert_str(start_button.text).is_equal("Start Game")
	assert_bool(settings_button.visible).is_true()
	assert_str(settings_button.text).is_equal("Settings")
	assert_bool(quit_button.visible).is_true()
	assert_str(quit_button.text).is_equal("Quit")

	ui.queue_free()


func test_settings_menu_has_display_audio_and_control_options() -> void:
	var settings := SETTINGS_MENU_SCENE.instantiate() as SettingsMenu
	add_child(settings)

	var tabs: TabContainer = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs")
	var resolution: OptionButton = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Display/ResolutionOption")
	var fullscreen: CheckButton = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Display/FullscreenCheck")
	var volume: HSlider = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Audio/MasterVolumeSlider")
	var mute: CheckButton = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Audio/MuteCheck")
	var move_left: Button = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Controls/MoveLeftButton")
	var move_right: Button = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Controls/MoveRightButton")
	var jump: Button = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Controls/JumpButton")

	assert_int(tabs.get_tab_count()).is_equal(3)
	assert_str(tabs.get_tab_title(0)).is_equal("Display")
	assert_str(tabs.get_tab_title(1)).is_equal("Audio")
	assert_str(tabs.get_tab_title(2)).is_equal("Controls")
	assert_int(resolution.item_count).is_equal(2)
	assert_bool(fullscreen.visible).is_true()
	assert_bool(volume.visible).is_true()
	assert_bool(mute.visible).is_true()
	assert_bool(move_left.visible).is_true()
	assert_bool(move_right.visible).is_true()
	assert_bool(jump.visible).is_true()
	assert_bool(InputMap.has_action(&"move_left")).is_true()
	assert_bool(InputMap.has_action(&"move_right")).is_true()
	assert_bool(InputMap.has_action(&"jump")).is_true()

	settings.queue_free()


func test_control_button_rebinds_its_input_action() -> void:
	var settings := SETTINGS_MENU_SCENE.instantiate() as SettingsMenu
	add_child(settings)

	var move_left: Button = settings.get_node("CenterContainer/Panel/Margin/Content/Tabs/Controls/MoveLeftButton")
	move_left.pressed.emit()
	assert_str(move_left.text).is_equal("Press a key...")

	var new_key := InputEventKey.new()
	new_key.physical_keycode = KEY_J
	new_key.pressed = true
	settings._input(new_key)

	var events := InputMap.action_get_events(&"move_left")
	assert_bool(events[0] is InputEventKey).is_true()
	assert_int((events[0] as InputEventKey).physical_keycode).is_equal(KEY_J)
	assert_str(move_left.text).is_equal("Move Left: J")

	var reset_key := InputEventKey.new()
	reset_key.physical_keycode = KEY_A
	settings.apply_rebind(&"move_left", reset_key)
	settings.queue_free()
