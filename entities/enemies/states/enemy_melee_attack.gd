class_name EnemyMeleeAttack
extends State

# Stop and request attacks while the target is in melee range, resume pursuit when it leaves range
func physics_update(_delta: float) -> void:
	var enemy := parent as Enemy
	enemy.velocity = Vector2.ZERO
	if not enemy.has_target():
		state_transition.emit(enemy.idle_state)
	elif enemy.uses_range():
		state_transition.emit(enemy.ranged_state)
	elif enemy.global_position.distance_to(enemy.target.global_position) > enemy.attack_range:
		state_transition.emit(enemy.walk_state)
	else:
		enemy.try_attack(false)
