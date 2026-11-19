class_name EnemyWalk
extends State

# Chase until melee range
func physics_update(delta: float) -> void:
	var enemy := parent as Enemy
	if not enemy.has_target():
		state_transition.emit(enemy.idle_state)
		return
	if enemy.uses_range():
		state_transition.emit(enemy.ranged_state)
		return

	# Attack if in range
	var offset := enemy.target.global_position - enemy.global_position
	var distance := offset.length()
	if distance <= enemy.attack_range:
		state_transition.emit(enemy.melee_state)
		return

	# Go in straight line, spiral, or zigzag depending on strategy
	enemy.approach_time += delta
	var heading := offset / distance
	match enemy.strategy:
		Enemy.Strategy.SPIRAL:
			heading = heading.rotated(1.05)
		Enemy.Strategy.ZIGZAG:
			heading = heading.rotated(0.95 * signf(sin(enemy.approach_time * 11.0)))

	enemy.velocity = heading * minf(enemy.speed, distance / delta)
	enemy.move_and_slide()
