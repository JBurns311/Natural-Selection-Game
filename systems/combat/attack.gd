class_name Attack extends Area2D

@export var power: int = 10
@export var knockback_distance: float = 100

func enable_collisions() -> void:
	$CollisionShape2D.set_deferred("disabled", false)
	
func disable_collisions() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
