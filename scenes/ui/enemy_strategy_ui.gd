class_name EnemyStrategyUI
extends Control

const Enemy = preload("res://entities/enemies/enemy.gd")
const HIGHEST_OUTPUT_COLOR := Color(0.4, 1.0, 0.5, 1.0)
const STRATEGY_DESCRIPTIONS := [
	"Moves directly toward the player and uses melee attacks.",
	"Moves in a spiral toward the player and uses melee attacks.",
	"Moves in a zigzag pattern toward the player and uses melee attacks.",
	"Stays in one place and fires ranged attacks at the player.",
	"Circles the player and fires ranged attacks.",
]

var selected_enemy_index: int = 0
var _enemy_buttons: Array[Button]
var _detail_title_template: String


func _ready() -> void:
	_enemy_buttons = [
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Enemy1Button as Button,
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Enemy2Button as Button,
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Enemy3Button as Button,
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Enemy4Button as Button,
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Enemy5Button as Button,
	]
	for index in range(_enemy_buttons.size()):
		_enemy_buttons[index].toggle_mode = true
		_enemy_buttons[index].pressed.connect(_select_enemy.bind(index))
		_update_enemy_button(index)
	EnemyStrategyRegistry.strategy_changed.connect(_on_strategy_changed)
	$CenterContainer/Panel/Margin/Content/BackButton.pressed.connect(_on_back_pressed)
	_detail_title_template = $CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailTitle.text
	_select_enemy(selected_enemy_index)


func _select_enemy(index: int) -> void:
	selected_enemy_index = clampi(index, 0, _enemy_buttons.size() - 1)
	for button_index in range(_enemy_buttons.size()):
		_enemy_buttons[button_index].button_pressed = button_index == selected_enemy_index
	var detail_title: Label = $CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailTitle
	var detail_description: Label = $CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailDescription
	var strategy_index: int = EnemyStrategyRegistry.current_strategies[selected_enemy_index]
	detail_title.text = _detail_title_template.replace("{enemy}", str(selected_enemy_index + 1)).replace("{strategy}", Enemy.STRATEGY_NAMES[strategy_index])
	detail_description.text = STRATEGY_DESCRIPTIONS[strategy_index]
	_update_output_highlight(strategy_index)


func _update_enemy_button(enemy_index: int) -> void:
	var strategy_index: int = EnemyStrategyRegistry.current_strategies[enemy_index]
	_enemy_buttons[enemy_index].text = "Enemy %d: %s" % [enemy_index + 1, Enemy.STRATEGY_NAMES[strategy_index]]


func _update_output_highlight(highest_output_index: int) -> void:
	var output_layer: VBoxContainer = $CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/Layers/OutputLayer
	for index in range(Enemy.STRATEGY_NAMES.size()):
		var output_node: Label = output_layer.get_node("OutputNode%d" % (index + 1))
		output_node.modulate = HIGHEST_OUTPUT_COLOR if index == highest_output_index else Color.WHITE


func _on_strategy_changed(enemy_index: int, _strategy_index: int, _generation: int) -> void:
	_update_enemy_button(enemy_index)
	if enemy_index == selected_enemy_index:
		_select_enemy(selected_enemy_index)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/game_ui.tscn")
