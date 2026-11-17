extends Node2D

const Brain = preload("res://entities/enemies/enemy_neural_net.gd")
const Enemy = preload("res://entities/enemies/enemy.gd")
const ENEMY_SCENE = preload("res://entities/enemies/enemy.tscn")
const STRATEGIES := ["Direct", "Spiral", "Zigzag"]
const COLORS := [Color.PALE_GREEN, Color.LIGHT_SALMON, Color.PLUM]
const TRIAL_SECONDS := 15.0
const COUNTER_RANGE := 65.0

@export_range(1, 12) var enemy_count: int = 3
@export_node_path("Node2D") var player_path: NodePath

@onready var dummy: Node2D = $Target
@onready var status: Label = $Status

var target: Node2D
var population: Array[Brain] = []
var enemies: Array[Enemy] = []
var counter_cooldowns: Array[float] = []
var generation := 1
var elapsed := 0.0
var last_result := "Evaluating the initial population"


func _ready() -> void:
	target = dummy
	if not player_path.is_empty():
		target = get_node_or_null(player_path) as Node2D
		if target == null:
			status.text = "Player Path must point to a Node2D."
			set_physics_process(false)
			return

	for index in range(enemy_count):
		var strategy_index := index % STRATEGIES.size()
		var brain := Brain.new()
		brain.biases[strategy_index] = 0.35
		population.append(brain)

		var enemy := ENEMY_SCENE.instantiate() as Enemy
		enemy.target = target
		enemy.scale = Vector2(2.5, 2.5)
		enemy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		enemy.modulate = COLORS[strategy_index]
		# Every in-range attack connects against the practice dummy.
		enemy.attack_requested.connect(enemy.record_hit_scored)
		add_child(enemy)
		var number := Label.new()
		number.text = str(index + 1)
		number.position = Vector2(-5.0, -21.0)
		number.scale = Vector2(0.4, 0.4)
		enemy.add_child(number)
		enemies.append(enemy)
		counter_cooldowns.append(0.0)

	_start_generation()


func _start_generation() -> void:
	elapsed = 0.0
	for index in range(enemies.size()):
		var angle := PI + TAU * index / enemies.size()
		var spawn := target.global_position + Vector2.from_angle(angle) * 225.0
		var enemy := enemies[index]
		enemy.reset_trial(spawn)
		enemy.strategy = population[index].choose_strategy(225.0 / 400.0)
		counter_cooldowns[index] = 0.0


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		status.text = "Trial stopped: the target was removed."
		for enemy in enemies:
			enemy.target = null
		set_physics_process(false)
		return

	elapsed += delta
	status.text = "Generation %d  |  %.1fs left\n%s" % [
		generation, maxf(0.0, TRIAL_SECONDS - elapsed), last_result
	]

	for index in range(enemies.size()):
		var enemy := enemies[index]
		counter_cooldowns[index] -= delta
		if counter_cooldowns[index] <= 0.0 and enemy.global_position.distance_to(target.global_position) <= COUNTER_RANGE:
			enemy.record_hit_taken()
			counter_cooldowns[index] = 1.0

		status.text += "\n#%d %s  |  Landed %d  |  Taken %d  |  Fitness %d" % [
			index + 1, STRATEGIES[enemy.strategy],
			enemy.hits_scored_on_player, enemy.hits_taken, enemy.fitness()
		]

	if elapsed >= TRIAL_SECONDS:
		_finish_generation()


func _finish_generation() -> void:
	var best := 0
	for index in range(1, enemies.size()):
		if enemies[index].fitness() > enemies[best].fitness():
			best = index

	last_result = "Generation %d winner: %s (fitness %d)" % [
		generation, STRATEGIES[enemies[best].strategy], enemies[best].fitness()
	]
	var winner := population[best]
	population[0] = winner
	for index in range(1, population.size()):
		population[index] = winner.mutated_copy()

	generation += 1
	_start_generation()


func _draw() -> void:
	if player_path.is_empty():
		draw_circle(dummy.position, COUNTER_RANGE, Color(0.33, 0.55, 0.65, 0.35))
		draw_circle(dummy.position, 12.0, Color.SKY_BLUE)
