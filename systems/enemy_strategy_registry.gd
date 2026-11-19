extends Node

signal strategy_changed(enemy_index: int, strategy_index: int, generation: int)

const ENEMY_COUNT := 5
const STRATEGY_COUNT := 5

var current_strategies: Array[int] = [0, 1, 2, 3, 4]
var current_generation: int = 1


func _process(_delta: float) -> void:
	var current_scene := get_tree().current_scene
	if not is_instance_valid(current_scene):
		return
	var controller := current_scene.get_node_or_null("EnemyController")
	if not is_instance_valid(controller):
		return
	var enemies: Array = controller.get("enemies")
	var generation := int(controller.get("generation"))
	for index in range(mini(enemies.size(), ENEMY_COUNT)):
		var enemy := enemies[index] as Node
		if is_instance_valid(enemy):
			var strategy_index := int(enemy.get("strategy"))
			if current_strategies[index] != strategy_index:
				set_enemy_strategy(index, strategy_index, generation)
	current_generation = generation


func set_enemy_strategy(enemy_index: int, strategy_index: int, generation: int) -> void:
	if enemy_index < 0 or enemy_index >= ENEMY_COUNT:
		return
	if strategy_index < 0 or strategy_index >= STRATEGY_COUNT:
		return
	if current_strategies[enemy_index] == strategy_index:
		current_generation = generation
		return
	current_strategies[enemy_index] = strategy_index
	current_generation = generation
	strategy_changed.emit(enemy_index, strategy_index, generation)
