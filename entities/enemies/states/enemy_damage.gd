class_name EnemyDamage extends State

var _remaining: float

var enemy: Enemy

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	enemy = parent as Enemy

func enter() -> void:
	enemy.sprite.play("take_damage")
	_remaining = 0.15
	enemy.sprite.self_modulate = Color.RED
	enemy.move_and_slide()

func physics_update(delta: float) -> void:
	var enemy := parent as Enemy
	enemy.velocity = Vector2.ZERO
	_remaining -= delta
	if _remaining <= 0.0:
		state_transition.emit(enemy.idle_state)

func exit() -> void:
	enemy.sprite.play("default")
	enemy.update_strategy_display()
