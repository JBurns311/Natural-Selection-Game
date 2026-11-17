class_name State extends Node

signal state_transition(new_state: State)

var parent: CharacterBody2D

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
	
func frame_update(_delta: float) -> void:
	pass
