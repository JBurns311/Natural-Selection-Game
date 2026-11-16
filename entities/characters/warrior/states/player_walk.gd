class_name PlayerWalk extends State

var player: Player = parent as Player

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player

func enter() -> void:
	player.sprite.play("walk")

func physics_update(_delta: float) -> void:
	player.move(_delta, Input.get_vector("left", "right", "up", "down"))
	
	if Input.is_action_just_pressed("primary_action"):
		state_transition.emit(player.basic_attack_state)
	elif player.input_direction == Vector2.ZERO:
		state_transition.emit(player.idle_state)
