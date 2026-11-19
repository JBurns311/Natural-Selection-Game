class_name PlayerComboAttack extends State

var player: Player
var attack_direction: String

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player
	
func enter() -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	attack_direction = "side"
	if input_direction.x > 0:
<<<<<<< HEAD
		player.sprite.flip_h = false
	elif input_direction.x < 0:
		player.sprite.flip_h = true
	elif input_direction.y > 0:
		attack_direction = "down"
	elif input_direction.y < 0:
		attack_direction = "up"
	
=======
		player.sword_attack.rotation_degrees = 0
		player.sprite.flip_h = false
	elif input_direction.x < 0:
		player.sprite.flip_h = true
		player.sword_attack.rotation_degrees = 180
	elif input_direction.y > 0:
		attack_direction = "down"
		player.sword_attack.rotation_degrees = 90
	elif input_direction.y < 0:
		attack_direction = "up"
		player.sword_attack.rotation_degrees = 270
	else:
		if player.sprite.flip_h:
			player.sword_attack.rotation_degrees = 180
		else:
			player.sword_attack.rotation_degrees = 0
	
	player.sword_attack.enable_collisions()
>>>>>>> origin/main
	player.sprite.play(attack_direction + "_attack_2")

func physics_update(_delta: float) -> void:
	# if player velocity isn't zero in state move towards that
	player.move(_delta, Vector2.ZERO)
	
<<<<<<< HEAD
=======
	if player.handle_death:
		state_transition.emit(player.death_state)
	elif player.handle_damage_taken:
		state_transition.emit(player.damage_state)
	
>>>>>>> origin/main
	if !player.sprite.is_playing():
		if Input.get_vector("left", "right", "up", "down") == Vector2.ZERO:
			state_transition.emit(player.idle_state)
		else:
			state_transition.emit(player.walk_state)
<<<<<<< HEAD
=======

func exit() -> void:
	player.sword_attack.disable_collisions()
>>>>>>> origin/main
