class_name StateMachine extends Node

@export var initial_state: State
var _current_state: State

func init(state_actor: CharacterBody2D) -> void:
	for child in get_children():
		if child is State:
			child.parent = state_actor
			child.state_transition.connect(change_state)
			child.init(state_actor)
	_current_state = initial_state
	_current_state.enter()

func _physics_process(delta: float) -> void:
	if _current_state:
		_current_state.physics_update(delta)
	

func _process(delta: float) -> void:
	if _current_state:
		_current_state.frame_update(delta)

func change_state(new_state: State) -> void:
	if new_state == null or _current_state == new_state:
		print("Error: " + get_parent().name + "invalid state transition signal")
		return
		
	if _current_state:
		_current_state.exit()
	_current_state = new_state
	_current_state.enter()
