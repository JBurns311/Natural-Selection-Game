class_name PlayerDamage extends State

var player: Player

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player

func enter() -> void:
	player.sprite.play("damage")
	
func physics_update(delta: float) -> void:
	player.move(delta, Vector2.ZERO)
	
	if not player.sprite.is_playing():
		if Input.is_action_just_pressed("primary_action"):
			state_transition.emit(player.basic_attack_state)
		elif Input.get_vector("left", "right", "up", "down") == Vector2.ZERO:
			state_transition.emit(player.idle_state)
		else:
			state_transition.emit(player.walk_state)
	
func exit() -> void:
	player.handle_damage_taken = false
