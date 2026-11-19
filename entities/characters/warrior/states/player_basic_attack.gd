class_name PlayerBasicAttack extends State

@onready var combo_timer: Timer = $ComboTimer

var player: Player
var attack_direction: String
# var combo_flag: bool

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player
	
func enter() -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	player.input_buffer.enable(true)
	attack_direction = "side"
	if input_direction.x > 0:
		player.sprite.flip_h = false
	elif input_direction.x < 0:
		player.sprite.flip_h = true
	elif input_direction.y > 0:
		attack_direction = "down"
	elif input_direction.y < 0:
		attack_direction = "up"
	
	player.sprite.play(attack_direction + "_attack_1")
	combo_timer.start()

func physics_update(_delta: float) -> void:
	# if player velocity isn't zero in state move towards that
	player.move(_delta, Vector2.ZERO)
	
	if combo_timer.is_stopped():
		var input_direction = Input.get_vector("left", "right", "up", "down")

		if player.input_buffer.is_full():
			var queued_action: String = player.input_buffer.pop()
			if queued_action == "primary_action":
				state_transition.emit(player.combo_attack_state)
			elif queued_action == "dash" and input_direction != Vector2.ZERO:
				print("Dash State Entered from Basic Attack State")
				state_transition.emit(player.dash_state)
		elif input_direction == Vector2.ZERO:
			state_transition.emit(player.idle_state)
		else:
			state_transition.emit(player.walk_state)

func exit() -> void:
	player.input_buffer.enable(false)
