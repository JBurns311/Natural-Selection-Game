class_name PlayerBasicAttack extends State

@onready var combo_timer: Timer = $ComboTimer

var player: Player
var attack_direction: String
var combo_flag: bool

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player
	
func enter() -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	combo_flag = false
	attack_direction = "side"
	if input_direction.x > 0:
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
	
	player.sprite.play(attack_direction + "_attack_1")
	player.sword_attack.enable_collisions()
	combo_timer.start()

func physics_update(delta: float) -> void:
	# if player velocity isn't zero in state move towards that
	player.move(delta, Vector2.ZERO)
	
	if Input.is_action_just_pressed("primary_action"):
		combo_flag = true
	
	# death and damage states will cancel an attack 
	if player.handle_death:
		state_transition.emit(player.death_state)
	elif player.handle_damage_taken:
		state_transition.emit(player.damage_state)
	
	if combo_timer.is_stopped():
		if combo_flag:
			state_transition.emit(player.combo_attack_state)
		elif Input.get_vector("left", "right", "up", "down") == Vector2.ZERO:
			state_transition.emit(player.idle_state)
		else:
			state_transition.emit(player.walk_state)

func exit() -> void:
	player.sword_attack.disable_collisions()
	combo_flag = false
	combo_timer.stop()
