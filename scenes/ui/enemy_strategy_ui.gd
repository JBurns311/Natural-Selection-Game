class_name EnemyStrategyUI
extends Control

var selected_strategy_index: int = 0
var _strategy_buttons: Array[Button]
var _detail_title_template: String


func _ready() -> void:
	_strategy_buttons = [
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Strategy1Button as Button,
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Strategy2Button as Button,
		$CenterContainer/Panel/Margin/Content/MainColumns/StrategyPanel/StrategyMargin/StrategyList/Strategy3Button as Button,
	]
	for index in range(_strategy_buttons.size()):
		_strategy_buttons[index].pressed.connect(_select_strategy.bind(index))
	$CenterContainer/Panel/Margin/Content/BackButton.pressed.connect(_on_back_pressed)
	_detail_title_template = $CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailTitle.text
	_select_strategy(selected_strategy_index)


func _select_strategy(index: int) -> void:
	selected_strategy_index = clampi(index, 0, _strategy_buttons.size() - 1)
	for button_index in range(_strategy_buttons.size()):
		_strategy_buttons[button_index].button_pressed = button_index == selected_strategy_index
	var detail_title: Label = $CenterContainer/Panel/Margin/Content/MainColumns/DetailsPanel/DetailsMargin/DetailsContent/DetailTitle
	detail_title.text = _detail_title_template.replace("{number}", str(selected_strategy_index + 1))


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/game_ui.tscn")
