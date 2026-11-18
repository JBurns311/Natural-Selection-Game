class_name PlayerDeath extends State

var player: Player

func init(state_actor: CharacterBody2D) -> void:
	parent = state_actor
	player = parent as Player

func enter() -> void:
	print("You Died!")
	player.sprite.stop()
	player.player_death.emit()
	
func physics_update(delta: float) -> void:
	player.move(delta, Vector2.ZERO)
	
	if not player.handle_death:
		state_transition.emit(player.idle_state)
	
func exit() -> void:
	player.hp_component.hp = player.hp_component.max_hp
