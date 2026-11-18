class_name Enemy
extends CharacterBody2D

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

# strategy variable defined here
@export_enum("Direct", "Spiral", "Zigzag", "Stationary Ranged", "Circling Ranged") var strategy: int = Strategy.DIRECT:
	set(value):
		strategy = value
		if is_node_ready():
			_update_strategy_display()
			
# Movement, cooldown, and range settings used by the enemy states
@export var speed: float = 120.0
@export var attack_range: float = 24.0
@export var attack_interval: float = 0.7
@export var ranged_attack_range: float = 270.0
@export var orbit_radius: float = 150.0

@onready var state_machine: StateMachine = $StateMachine
@onready var idle_state: State = $StateMachine/EnemyIdle
@onready var walk_state: State = $StateMachine/EnemyWalk
@onready var melee_state: State = $StateMachine/EnemyMeleeAttack
@onready var ranged_state: State = $StateMachine/EnemyRangeAttack
@onready var tracer: Line2D = $ShotTracer

var target: Node2D
var hits_taken: int = 0
var hits_scored_on_player: int = 0
var approach_time: float = 0.0
var _cooldown: float = 0.0
var _tracer_time: float = 0.0

func _ready() -> void:
	_update_strategy_display()
	state_machine.init(self)

# Update enemy color and label when a strategy is assigned
func _update_strategy_display() -> void:
	$AnimatedSprite2D.self_modulate = STRATEGY_COLORS.get(strategy, Color.WHITE)
	$StrategyLabel.text = STRATEGY_NAMES[strategy] if STRATEGY_COLORS.has(strategy) else "Unknown"


# The target can disappear if the level removes it during a trial
func has_target() -> bool:
	return is_instance_valid(target) and not target.is_queued_for_deletion()


# Both ranged strategies share a state and differ in how they move
func uses_range() -> bool:
	return strategy == Strategy.STATIONARY_RANGE or strategy == Strategy.CIRCLE_RANGE


# Reuse the slime at a new spawn position with fresh timers and hit counters
func reset_trial(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	hits_taken = 0
	hits_scored_on_player = 0
	approach_time = 0.0
	_cooldown = 0.0
	_tracer_time = 0.0
	tracer.hide()

func record_hit_taken() -> void:
	hits_taken += 1

func record_hit_scored() -> void:
	hits_scored_on_player += 1

# Compare candidates using hits landed minus hits taken
func fitness() -> int:
	return hits_scored_on_player - hits_taken

# Advance the shared cooldown and tracer timer while states handle movement and attack decisions
func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	_tracer_time = maxf(0.0, _tracer_time - delta)
	tracer.visible = _tracer_time > 0.0

# Apply the cooldown and emit the requested attack. The ranged tracer is visual only.
# It does not check collisions or apply damage.
func try_attack(ranged: bool) -> void:
	if _cooldown > 0.0:
		return
	_cooldown = attack_interval
	if ranged:
		var aim_point := target.global_position
		tracer.points = PackedVector2Array([Vector2.ZERO, to_local(aim_point)])
		_tracer_time = 0.12
		tracer.show()
		ranged_attack_requested.emit(global_position, global_position.direction_to(aim_point))
		return
	attack_requested.emit()
