class_name EnemyDamage extends State

var _remaining: float

func enter() -> void:
	_remaining = 0.15

func physics_update(delta: float) -> void:
	var enemy := parent as Enemy
	enemy.velocity = Vector2.ZERO
	_remaining -= delta
	if _remaining <= 0.0:
		state_transition.emit(enemy.idle_state)
