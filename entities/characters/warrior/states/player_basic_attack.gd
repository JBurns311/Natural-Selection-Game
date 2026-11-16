class_name PlayerBasicAttack extends State

@onready var combo_timer: Timer = $ComboTimer

var player: Player
var attack_direction: String
var combo_flag: bool

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player
	
func enter() -> void:
	combo_flag = false
	attack_direction = "side"
	if player.input_direction.x > 0:
		player.sprite.flip_h = false
	elif player.input_direction.x < 0:
		player.sprite.flip_h = true
	elif player.input_direction.y > 0:
		attack_direction = "down"
	elif player.input_direction.y < 0:
		attack_direction = "up"
	
	player.sprite.play(attack_direction + "_attack_1")
	combo_timer.start()

func physics_update(_delta: float) -> void:
	# if player velocity isn't zero in state move towards that
	player.move(_delta, Vector2.ZERO)
	
	if Input.is_action_just_pressed("primary_action"):
		combo_flag = true
	
	if combo_timer.is_stopped():
		if combo_flag:
			state_transition.emit(player.combo_attack_state)
		elif player.input_direction == Vector2.ZERO:
			state_transition.emit(player.idle_state)
		else:
			state_transition.emit(player.walk_state)

func exit() -> void:
	combo_flag = false
