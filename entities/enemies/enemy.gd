extends Node2D

signal attack_requested

@export_enum("Direct", "Spiral", "Zigzag") var strategy: int = 0
@export var speed: float = 120.0
@export var attack_range: float = 24.0
@export var attack_interval: float = 0.7

var target: Node2D
var hits_taken: int = 0
var hits_scored_on_player: int = 0
var _elapsed: float = 0.0
var _cooldown: float = 0.0


func reset_trial(spawn_position: Vector2) -> void:
	global_position = spawn_position
	hits_taken = 0
	hits_scored_on_player = 0
	_elapsed = 0.0
	_cooldown = 0.0


func record_hit_taken() -> void:
	hits_taken += 1


func record_hit_scored() -> void:
	hits_scored_on_player += 1


func fitness() -> int:
	return hits_scored_on_player - hits_taken


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	_elapsed += delta
	_cooldown = maxf(0.0, _cooldown - delta)
	var offset := target.global_position - global_position
	var distance := offset.length()
	if distance <= attack_range:
		if _cooldown <= 0.0:
			_cooldown = attack_interval
			attack_requested.emit()
		return

	var heading := offset / distance
	match strategy:
		1:
			heading = heading.rotated(1.05)
		2:
			heading = heading.rotated(0.95 * signf(sin(_elapsed * 11.0)))

	global_position += heading * minf(speed * delta, distance)
