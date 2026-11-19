class_name InputBuffer extends Node

var _action_queue: String = "dash"
var _is_full: bool = false
var _should_queue: bool = false

func _physics_process(_delta: float) -> void:
	if _should_queue:
		if Input.is_action_just_pressed("dash"):
			_action_queue = "dash"
			_is_full = true
		if Input.is_action_just_pressed("primary_action"):
			_action_queue = "primary_action"
			_is_full = true

func pop() -> String:
	_is_full = false
	return _action_queue

func is_full() -> bool:
	if _should_queue:
		return _is_full
	else:
		return false

func clear() -> void:
	_is_full = false

func enable(should_queue: bool) -> void:
	_should_queue = should_queue

