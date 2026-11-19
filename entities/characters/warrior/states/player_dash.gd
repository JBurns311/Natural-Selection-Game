class_name PlayerDash extends State

var player: Player = parent as Player

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player

func enter() -> void:
	print("Dash State Entered")
	player.move(0.15, Input.get_vector("left", "right", "up", "down"))
	player.sprite.play("dash")
	var tween := get_tree().create_tween()
	tween.tween_property(player.sprite, "modulate", Color.BLACK, .15)
	tween.tween_property(player.sprite, "modulate", Color.WHITE, 0)

func physics_update(_delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	player.move(_delta, Vector2.ZERO)

	# state transition
	if player.velocity == Vector2.ZERO:
		if Input.is_action_just_pressed("primary_action"): # FIX: should really implement full input buffer
			state_transition.emit(player.basic_attack_state)
		elif input_direction == Vector2.ZERO:
			state_transition.emit(player.idle_state)
		elif Input.is_action_just_pressed("dash"):
			print("Dash State Entered from Dash State")
			state_transition.emit(player.dash_state)
		else:
			state_transition.emit(player.walk_state)
