class_name Player extends CharacterBody2D

@export var speed = 300.0

var input_direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

#state imports
@onready var idle_state: State = $StateMachine/PlayerIdle
@onready var walk_state: PlayerWalk = $StateMachine/PlayerWalk
@onready var basic_attack_state: PlayerBasicAttack = $StateMachine/PlayerBasicAttack
@onready var combo_attack_state: PlayerComboAttack = $StateMachine/PlayerComboAttack


func _ready() -> void:
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	
func move(delta: float, input_direction: Vector2) -> void:
	var input_velocity = input_direction * speed
	
	if input_direction.x < 0:
		sprite.flip_h = true
	elif input_direction.x > 0:
		sprite.flip_h = false
	
	velocity.x = move_toward(velocity.x, input_velocity.x, speed)
	velocity.y = move_toward(velocity.y, input_velocity.y, speed)
	move_and_slide()
