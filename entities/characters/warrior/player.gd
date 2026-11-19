class_name Player extends CharacterBody2D

@export var speed: float = 18000.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var input_buffer: InputBuffer = $InputBuffer

#state imports
@onready var idle_state: State = $StateMachine/PlayerIdle
@onready var walk_state: PlayerWalk = $StateMachine/PlayerWalk
@onready var basic_attack_state: PlayerBasicAttack = $StateMachine/PlayerBasicAttack
@onready var combo_attack_state: PlayerComboAttack = $StateMachine/PlayerComboAttack
@onready var dash_state: PlayerDash = $StateMachine/PlayerDash



func _ready() -> void:
	state_machine.init(self)

func _physics_process(_delta: float) -> void:
	pass
	# input_direction = Input.get_vector("left", "right", "up", "down")
	
func move(delta: float, direction: Vector2) -> void:
	var delta_speed = speed * delta
	var delta_velocity = direction.normalized() * delta_speed
	
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
	
	velocity.x = move_toward(velocity.x, delta_velocity.x, delta_speed)
	velocity.y = move_toward(velocity.y, delta_velocity.y , delta_speed)

	move_and_slide()
