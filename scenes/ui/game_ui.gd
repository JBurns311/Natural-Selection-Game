extends Control


func _ready() -> void:
	$CenterContainer/Menu/ResumeButton.pressed.connect(_on_resume_pressed)
	$CenterContainer/Menu/EnemyStrategyButton.pressed.connect(_on_enemy_strategy_pressed)


func _on_resume_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/test_level.tscn")


func _on_enemy_strategy_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/enemy_strategy_ui.tscn")
