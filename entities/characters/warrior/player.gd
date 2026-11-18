class_name Player extends CharacterBody2D

@warning_ignore("unused_signal")

# exported consts
@export var speed: float = 18000.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var hp_component: HealthComponent = $HealthComponent
@onready var sword_attack: Attack = $SwordAttack

#state imports
@onready var idle_state: State = $StateMachine/PlayerIdle
@onready var walk_state: PlayerWalk = $StateMachine/PlayerWalk
@onready var basic_attack_state: PlayerBasicAttack = $StateMachine/PlayerBasicAttack
@onready var combo_attack_state: PlayerComboAttack = $StateMachine/PlayerComboAttack
@onready var damage_state: PlayerDamage = $StateMachine/PlayerDamage
@onready var death_state: PlayerDeath = $StateMachine/PlayerDeath


var handle_damage_taken: bool = false
var handle_death: bool = false

signal player_death()

func _ready() -> void:
	state_machine.init(self)

func _physics_process(_delta: float) -> void:
	pass
	
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

func process_attack(attack: Attack) -> void:
	if not handle_damage_taken and not handle_death:
		hp_component.hp = max(hp_component.hp - attack.power, 0)
		var knockback_vel := (position - attack.position).normalized() * attack.knockback_distance
		velocity.x = move_toward(velocity.x, knockback_vel.x, attack.knockback_distance)
		velocity.y = move_toward(velocity.y, knockback_vel.y, attack.knockback_distance)
		if hp_component.hp > 0:
			handle_damage_taken = true
		else:
			handle_death = true


func _on_health_component_area_entered(area: Area2D) -> void:
	process_attack(area)
