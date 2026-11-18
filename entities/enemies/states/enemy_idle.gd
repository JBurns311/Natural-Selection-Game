class_name EnemyIdle
extends State


# Wait for a target, then dispatch to melee pursuit or ranged behavior.
func physics_update(_delta: float) -> void:
	var enemy := parent as Enemy
	enemy.velocity = Vector2.ZERO
	if enemy.has_target():
		state_transition.emit(enemy.ranged_state if enemy.uses_range() else enemy.walk_state)
