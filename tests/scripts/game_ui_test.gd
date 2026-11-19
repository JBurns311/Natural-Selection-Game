# GdUnit4 tests for the basic game title screen.
class_name GameUITest
extends GdUnitTestSuite

const GAME_UI_SCENE: PackedScene = preload("res://scenes/ui/game_ui.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")
const ENEMY_STRATEGY_SCENE: PackedScene = preload("res://scenes/ui/enemy_strategy_ui.tscn")

func test_title_screen_has_expected_title() -> void:
	var ui := GAME_UI_SCENE.instantiate()
	add_child(ui)

	var title: Label = ui.get_node("CenterContainer/Menu/Title")
	assert_str(title.text).is_equal("Natural Selection")

	ui.queue_free()


func test_title_screen_shows_start_and_quit_buttons() -> void:
	var ui := GAME_UI_SCENE.instantiate()
	add_child(ui)

	var menu: VBoxContainer = ui.get_node("CenterContainer/Menu")
	var resume_button: Button = ui.get_node("CenterContainer/Menu/ResumeButton")
	var strategy_button: Button = ui.get_node("CenterContainer/Menu/EnemyStrategyButton")
	var quit_button: Button = ui.get_node("CenterContainer/Menu/QuitButton")
	assert_int(menu.get_child_count()).is_equal(4)
	assert_bool(resume_button.visible).is_true()
	assert_str(resume_button.text).is_equal("Resume Game")
	assert_bool(resume_button.pressed.is_connected(Callable(ui, "_on_resume_pressed"))).is_true()
	assert_bool(strategy_button.visible).is_true()
	assert_str(strategy_button.text).is_equal("View Enemy Strategies")
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


func test_enemy_strategy_viewer_shows_network_layers() -> void:
	for index in range(5):
		EnemyStrategyRegistry.set_enemy_strategy(index, index, 1)

	var viewer := ENEMY_STRATEGY_SCENE.instantiate() as EnemyStrategyUI
	add_child(viewer)

	var title: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/Title")
	var columns: HBoxContainer = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns")
	var strategy_list: VBoxContainer = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList")
	var details_panel: PanelContainer = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel")
	var layers: HBoxContainer = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/Layers")
	var inputs: VBoxContainer = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/Layers/InputLayer")
	var input_node: Label = inputs.get_node("InputNode1")
	var outputs: VBoxContainer = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/Layers/OutputLayer")
	var output_title: Label = outputs.get_node("OutputTitle")
	var detail_title: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailTitle")
	var detail_description: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailDescription")
	var selection_rule: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/SelectionRule")
	var strategy_list_path := "CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList"
	var expected_strategies := ["Direct", "Spiral", "Zigzag", "Stationary Ranged", "Circling Ranged"]

	assert_str(title.text).is_equal("View Enemy Strategies")
	assert_str(detail_title.text).is_equal("Enemy 1 - Direct")
	assert_str(detail_description.text).is_equal("Moves directly toward the player and uses melee attacks.")
	assert_int(columns.get_child_count()).is_equal(2)
	assert_int(strategy_list.get_child_count()).is_equal(6)
	assert_bool(details_panel.visible).is_true()
	assert_int(layers.get_child_count()).is_equal(2)
	assert_int(inputs.get_child_count()).is_equal(2)
	assert_int(outputs.get_child_count()).is_equal(6)
	assert_str(input_node.text).is_equal("Distance from player")
	assert_str(output_title.text).is_equal("Output Layer")
	assert_str(selection_rule.text).is_equal("The strategy with the highest output value is chosen.")
	for index in range(5):
		var enemy_button: Button = viewer.get_node("%s/Enemy%dButton" % [strategy_list_path, index + 1])
		assert_str(enemy_button.text).is_equal("Enemy %d: %s" % [index + 1, expected_strategies[index]])
		var output_node: Label = outputs.get_node("OutputNode%d" % (index + 1))
		assert_str(output_node.text).is_equal(expected_strategies[index])

	viewer.queue_free()


func test_enemy_strategy_menu_updates_when_an_enemy_changes_strategy() -> void:
	EnemyStrategyRegistry.set_enemy_strategy(1, 1, 1)
	var viewer := ENEMY_STRATEGY_SCENE.instantiate() as EnemyStrategyUI
	add_child(viewer)

	var enemy_two: Button = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Enemy2Button")
	var detail_title: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailTitle")
	var detail_description: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailDescription")
	var spiral_output: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/Layers/OutputLayer/OutputNode2")
	var circle_output: Label = viewer.get_node("CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/Layers/OutputLayer/OutputNode5")
	enemy_two.pressed.emit()

	assert_int(viewer.selected_enemy_index).is_equal(1)
	assert_str(detail_title.text).is_equal("Enemy 2 - Spiral")
	assert_str(detail_description.text).is_equal("Moves in a spiral toward the player and uses melee attacks.")
	assert_bool(enemy_two.button_pressed).is_true()
	assert_bool(spiral_output.modulate == Color(0.4, 1.0, 0.5, 1.0)).is_true()

	EnemyStrategyRegistry.set_enemy_strategy(1, 4, 2)
	assert_str(enemy_two.text).is_equal("Enemy 2: Circling Ranged")
	assert_str(detail_title.text).is_equal("Enemy 2 - Circling Ranged")
	assert_str(detail_description.text).is_equal("Circles the player and fires ranged attacks.")
	assert_bool(spiral_output.modulate == Color.WHITE).is_true()
	assert_bool(circle_output.modulate == Color(0.4, 1.0, 0.5, 1.0)).is_true()

	viewer.queue_free()
	EnemyStrategyRegistry.set_enemy_strategy(1, 1, 1)


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
