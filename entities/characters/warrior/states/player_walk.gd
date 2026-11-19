class_name PlayerWalk extends State

var player: Player = parent as Player

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player

func enter() -> void:
	player.sprite.play("walk")

func physics_update(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	player.move(delta, input_direction)
	
<<<<<<< HEAD
	if Input.is_action_just_pressed("primary_action"):
=======
	if player.handle_death:
		state_transition.emit(player.death_state)
	elif player.handle_damage_taken:
		state_transition.emit(player.damage_state)
	elif Input.is_action_just_pressed("primary_action"):
>>>>>>> origin/main
		state_transition.emit(player.basic_attack_state)
	elif input_direction == Vector2.ZERO:
		state_transition.emit(player.idle_state)
