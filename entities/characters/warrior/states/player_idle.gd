class_name PlayerIdle extends State

var player: Player

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player

func enter() -> void:
	player.sprite.play("idle")

func physics_update(_delta: float) -> void:
	# player velocity isn't zero in idle state move towards that
	# i.e friction/air resistance
	player.move(_delta, Vector2.ZERO)
	
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
	elif Input.get_vector("left", "right", "up", "down") != Vector2.ZERO:
		state_transition.emit(player.walk_state)
