extends Control


func _ready() -> void:
	$CenterContainer/Menu/SettingsButton.pressed.connect(_on_settings_pressed)


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")
