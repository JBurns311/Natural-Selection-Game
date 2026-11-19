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
	var is_dash: bool = Input.is_action_just_pressed("dash")
	
	if Input.is_action_just_pressed("primary_action"):
		state_transition.emit(player.basic_attack_state)
	elif Input.get_vector("left", "right", "up", "down") != Vector2.ZERO and !is_dash:
		state_transition.emit(player.walk_state)
	elif is_dash:
		print("Dash State Entered from Idle State")
		state_transition.emit(player.dash_state)
