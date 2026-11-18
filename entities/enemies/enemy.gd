class_name Enemy
extends CharacterBody2D

const Attack_scene = preload("res://systems/combat/attack.tscn")
var active_attack: Attack

const max_health = 30
var health = max_health

signal attack_requested
signal ranged_attack_requested(origin: Vector2, direction: Vector2)

enum Strategy { DIRECT, SPIRAL, ZIGZAG, STATIONARY_RANGE, CIRCLE_RANGE }

# These are just placeholder strategies.
# Direct strategy: Go directly towards the player and do melee attacks
# Spiral strategy: Move in a spiral towards the player and do melee attacks
# Zigzag strategy: Move in a zigzag pattern towards the player and do melee attacks
# Stationary ranged strategy: Stay in one place and fire ranged attacks at the player
# Circling ranged strategy: Circle the player and fire ranged attacks
const STRATEGY_NAMES := ["Direct", "Spiral", "Zigzag", "Stationary Ranged", "Circling Ranged"]

# Colors (or color filters really) for enemies of each strategy
const STRATEGY_COLORS := {
	Strategy.DIRECT: Color.BLUE_VIOLET,
	Strategy.SPIRAL: Color.BLUE,
	Strategy.ZIGZAG: Color.SEA_GREEN,
	Strategy.STATIONARY_RANGE: Color.YELLOW,
	Strategy.CIRCLE_RANGE: Color.WHITE,
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# strategy variable defined here
@export_enum("Direct", "Spiral", "Zigzag", "Stationary Ranged", "Circling Ranged") var strategy: int = Strategy.DIRECT:
	set(value):
		strategy = value
		if is_node_ready():
			update_strategy_display()

# Movement, cooldown, and range settings used by the enemy states
@export var speed: float = 120.0
@export var attack_range: float = 24.0
@export var attack_interval: float = 0.7
@export var ranged_attack_range: float = 270.0
@export var orbit_radius: float = 150.0
@export var projectile_speed: float = 180.0

@onready var state_machine: StateMachine = $StateMachine
@onready var idle_state: State = $StateMachine/EnemyIdle
@onready var walk_state: State = $StateMachine/EnemyWalk
@onready var melee_state: State = $StateMachine/EnemyMeleeAttack
@onready var ranged_state: State = $StateMachine/EnemyRangeAttack
@onready var damage_state: State = $StateMachine/EnemyDamage

var target: Node2D
var hits_taken: int = 0
var hits_scored_on_player: int = 0
var approach_time: float = 0.0
var cooldown: float = 0.0
var projectiles: Array[Attack] = []

func _ready() -> void:
	update_strategy_display()
	state_machine.init(self)

# Update enemy color and label when a strategy is assigned
func update_strategy_display() -> void:
	sprite.self_modulate = STRATEGY_COLORS[strategy]
	$StrategyLabel.text = STRATEGY_NAMES[strategy]

func has_target() -> bool:
	return is_instance_valid(target) and not target.is_queued_for_deletion()

# Both ranged strategies share a state and differ in how they move
func uses_range() -> bool:
	return strategy == Strategy.STATIONARY_RANGE or strategy == Strategy.CIRCLE_RANGE

# Reuse the slime at a new spawn position with fresh timers and hit counters
# Input: new spawn location
func reset_trial(spawn_position: Vector2) -> void:
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	projectiles.clear()
	clear_active_attack()
	health = max_health
	show()
	state_machine.set_physics_process(true)
	if state_machine._current_state != idle_state:
		state_machine.change_state(idle_state)
	global_position = spawn_position
	velocity = Vector2.ZERO
	hits_taken = 0
	hits_scored_on_player = 0
	approach_time = 0.0
	cooldown = 0.0

func record_hit_scored() -> void:
	hits_scored_on_player += 1

# Compare candidates using hits landed minus hits taken
func fitness() -> int:
	return hits_scored_on_player - hits_taken

# Advance the projectiles and cooldown while states handle movement and attack decisions
func _physics_process(delta: float) -> void:
	# Shots keep their original direction so the player can move out of their path.
	for index in range(projectiles.size() - 1, -1, -1):
		var projectile := projectiles[index]
		if not is_instance_valid(projectile) or projectile.is_queued_for_deletion():
			projectiles.remove_at(index)
		else:
			projectile.global_position += projectile.get_meta("direction") * projectile_speed * delta
	cooldown = maxf(0.0, cooldown - delta)

# Create the attack and apply the cooldown.
func try_attack(ranged: bool) -> void:
	if cooldown > 0.0:
		return
	cooldown = attack_interval
	clear_active_attack()
	
	# Create the attack box
	var attack := Attack_scene.instantiate() as Attack
	add_child(attack)
	attack.connect("area_entered", _on_attack_area_entered.bind(attack))
	attack.enable_collisions()
	
	# Create the collision shape for the attack
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	var collision_shape = attack.get_node("CollisionShape2D") as CollisionShape2D
	collision_shape.shape = shape
	
	# Set the collision layer and mask
	attack.collision_layer = 1 << 4
	attack.collision_mask = 1 << 1
	
	# Determine where the target is
	var aim_point = target.global_position
	var direction = global_position.direction_to(aim_point)
	
	if ranged:
		attack.top_level = true
		attack.global_position = global_position
		attack.set_meta("direction", direction)
		projectiles.append(attack)
		# A visible circle travels with the attack's collision shape
		var visual := Polygon2D.new()
		var points := PackedVector2Array()
		for index in range(12):
			points.append(Vector2.from_angle(TAU * index / 12.0) * shape.radius)
		visual.polygon = points
		visual.color = Color.YELLOW
		attack.add_child(visual)
		get_tree().create_timer(3.0, false, true).timeout.connect(attack.queue_free)
		ranged_attack_requested.emit(global_position, direction)
	else:
		attack.global_position = global_position + direction * attack_range * 0.5
		active_attack = attack
		get_tree().create_timer(0.5, false, true).timeout.connect(attack.queue_free)
		attack_requested.emit()
		
func _on_attack_area_entered(area: Area2D, attack: Attack) -> void:
	if not attack.is_queued_for_deletion() and area is HealthComponent and area.get_parent() == target:
		record_hit_scored()
		attack.queue_free()

func clear_active_attack() -> void:
	if is_instance_valid(active_attack):
		active_attack.queue_free()
	active_attack = null

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Attack and health > 0:
		process_attack(area)

func process_attack(attack: Attack) -> void:
	hits_taken += 1
	health = max(health - attack.power, 0)
	if health > 0:
		if state_machine._current_state != damage_state:
			state_machine.change_state(damage_state)
	else:
		clear_active_attack()
		velocity = Vector2.ZERO
		hide()
		# Keep the defeated slime in the roster so the controller can score and reset it.
		state_machine.set_physics_process(false)
