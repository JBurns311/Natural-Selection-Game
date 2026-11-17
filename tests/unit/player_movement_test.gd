# GdUnit4 tests for Player.move().
class_name PlayerMovementTest
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://entities/characters/warrior/player.tscn")

var player: Player


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as Player
	add_child(player)


func after_test() -> void:
	player.queue_free()
	await get_tree().process_frame


func test_move_normalizes_diagonal_input_and_sets_velocity_to_speed() -> void:
	const delta = 1.0 / 60.0
	player.move(delta, Vector2(1.0, 1.0))

	var expected_component := player.speed / sqrt(2.0) * delta
	assert_vector(player.velocity).is_equal_approx(Vector2(expected_component, expected_component), player.velocity)
	assert_bool(player.sprite.flip_h).is_false()


func test_move_sets_facing_from_horizontal_input() -> void:
	player.sprite.flip_h = false
	player.move(1.0 / 60.0, Vector2.LEFT)
	assert_bool(player.sprite.flip_h).is_true()

	player.move(1.0 / 60.0, Vector2.RIGHT)
	assert_bool(player.sprite.flip_h).is_false()


func test_move_keeps_facing_for_vertical_or_zero_input() -> void:
	player.sprite.flip_h = true
	player.move(1.0 / 60.0, Vector2.UP)
	assert_bool(player.sprite.flip_h).is_true()

	player.move(1.0 / 60.0, Vector2.ZERO)
	assert_bool(player.sprite.flip_h).is_true()


func test_move_decelerates_toward_zero_without_input() -> void:
	player.velocity = Vector2(100.0, -100.0)
	player.move(1.0 / 60.0, Vector2.ZERO)

	assert_vector(player.velocity).is_equal_approx(Vector2.ZERO, Vector2(0.01, 0.01))
