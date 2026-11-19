class_name EnemyIdle
extends State

# Wait for a target, then dispatch to melee pursuit or ranged behavior
func physics_update(_delta: float) -> void:
	var enemy := parent as Enemy
	enemy.velocity = Vector2.ZERO
	if enemy.has_target():
		if enemy.uses_range():
			state_transition.emit(enemy.ranged_state)
		else: 
			state_transition.emit(enemy.walk_state)
