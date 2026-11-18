extends Node

# Bringing in outside scripts and scenes
const Enemy = preload("res://entities/enemies/enemy.gd")
const Enemy_scene = preload("res://entities/enemies/enemy.tscn")
const Neural_net = preload("res://entities/enemies/enemy_neural_net.gd")

# These (number of enemies, and path to player node) are editable in the inspector
@export_range(1, 12) var enemy_count: int = 5
@export_node_path("Node2D") var player_path: NodePath

# This will be the array of enemies. Their strategies are variables under each instantiation of the enemies,
# if GUI wants to access them
var enemies: Array[Enemy] = []

var nn_array: Array[Neural_net] = []
var counter_cooldowns: Array[float] = []

var generation := 1
var elapsed := 0.0

const TRIAL_SECONDS := 15.0
const COUNTER_RANGE := 65.0

var target: Node2D

func _ready() -> void:
	
	target = get_node_or_null(player_path)
	
	for index in range(enemy_count):
		
		# Creating new neural net
		# (Bias the initial networks toward different strategies so the default population shows them all)
		var strategy_index := index % Neural_net.OUTPUT_COUNT
		var neural_net := Neural_net.new()
		neural_net.biases[strategy_index] = 0.35
		nn_array.append(neural_net)

		# Creating new enemy
		var enemy := Enemy_scene.instantiate() as Enemy
		enemy.target = target
		enemy.scale = Vector2(2.5, 2.5)
		enemy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		# There are placeholder connections here for now until combat system is ready
		
		#TODO from combat system (connect to melee attack procedure)
		enemy.attack_requested.connect(enemy.record_hit_scored)
		#TODO from combat system (connect to ranged attack procedure)
		enemy.ranged_attack_requested.connect(func(_origin: Vector2, _direction: Vector2) -> void: enemy.record_hit_scored())
		
		add_child(enemy)
		enemies.append(enemy)
		counter_cooldowns.append(0.0)

	_start_generation()

# Reset and space the slimes around the target. Every network gets the same normalized starting distance.
func _start_generation() -> void:
	elapsed = 0.0
	for index in range(enemies.size()):
		var angle := PI + TAU * index / enemies.size()
		var spawn = target.global_position + Vector2.from_angle(angle) * 225.0
		var enemy := enemies[index]
		enemy.reset_trial(spawn)
		enemy.strategy = nn_array[index].choose_strategy(225.0 / 400.0)
		counter_cooldowns[index] = 0.0


# Advance the trial timer and simulate a separate counterattack cooldown for each slime.
func _physics_process(delta: float) -> void:
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		for enemy in enemies:
			enemy.target = null
		set_physics_process(false)
		return

	elapsed += delta

	for index in range(enemies.size()):
		var enemy := enemies[index]

		#TODO from combat system (create the actual conditions where record_hit_taken() gets called)
		# (instead of this simulated situation)
		counter_cooldowns[index] -= delta
		if counter_cooldowns[index] <= 0.0 and enemy.global_position.distance_to(target.global_position) <= COUNTER_RANGE:
			enemy.record_hit_taken()
			counter_cooldowns[index] = 1.0

	if elapsed >= TRIAL_SECONDS:
		_finish_generation()

# Keep the highest-fitness network and mutate copies for the rest
func _finish_generation() -> void:
	var best = 0
	for index in range(1, enemies.size()):
		if enemies[index].fitness() > enemies[best].fitness():
			best = index

	var winner = nn_array[best]
	nn_array[0] = winner
	for index in range(1, nn_array.size()):
		nn_array[index] = winner.mutated_copy()

	generation += 1
	_start_generation()
