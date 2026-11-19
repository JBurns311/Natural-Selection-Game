extends State

func physics_update(_delta: float) -> void:
	var enemy := parent as Enemy
	if not enemy.has_target():
		state_transition.emit(enemy.idle_state)
		return
	if not enemy.uses_range():
		state_transition.emit(enemy.walk_state)
		return

	var offset := enemy.global_position - enemy.target.global_position
	var distance := offset.length()
	enemy.velocity = Vector2.ZERO
	
	# Move in circular pattern if using circle range strategy
	if enemy.strategy == Enemy.Strategy.CIRCLE_RANGE:
		var outward := offset.normalized() if distance > 0.0 else Vector2.RIGHT
		var correction := clampf((enemy.orbit_radius - distance) / 48.0, -2.0, 2.0)
		enemy.velocity = (outward.orthogonal() + outward * correction).normalized() * enemy.speed
		enemy.move_and_slide()

	# Both variants request shots only when the target is in range
	if distance <= enemy.ranged_attack_range:
		enemy.try_attack(true)
