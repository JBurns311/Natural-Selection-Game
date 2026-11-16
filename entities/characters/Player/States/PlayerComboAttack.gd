class_name PlayerComboAttack extends State

var player: Player
var attack_direction: String

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player
	
func enter() -> void:
	attack_direction = "side"
	if player.input_direction.x > 0:
		player.sprite.flip_h = false
	elif player.input_direction.x < 0:
		player.sprite.flip_h = true
	elif player.input_direction.y > 0:
		attack_direction = "down"
	elif player.input_direction.y < 0:
		attack_direction = "up"
	
	player.sprite.play(attack_direction + "_attack_2")

func physics_update(_delta: float) -> void:
	# if player velocity isn't zero in state move towards that
	player.move(_delta, Vector2.ZERO)
	
	if !player.sprite.is_playing():
		if player.input_direction == Vector2.ZERO:
			state_transition.emit(player.idle_state)
		else:
			state_transition.emit(player.walk_state)
