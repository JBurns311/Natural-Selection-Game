# GdUnit4 integration tests for the warrior player's state machine.
class_name PlayerStateTransitionTest
extends GdUnitTestSuite
@warning_ignore("redundant_await")

const PLAYER_SCENE := "res://entities/characters/warrior/player.tscn"
const SIMULATED_ACTIONS: Array[String] = [
	"left",
	"right",
	"up",
	"down",
	"primary_action",
]


func after_test() -> void:
	for action in SIMULATED_ACTIONS:
		Input.action_release(action)
	Input.flush_buffered_events()
	await get_tree().process_frame
	await get_tree().physics_frame


func test_idle_and_walk_transition_with_directional_input() -> void:
	var runner := scene_runner(PLAYER_SCENE)
	var player := runner.scene() as Player

	assert_that(player.state_machine._current_state).is_equal(player.idle_state)
	assert_that(player.sprite.animation).is_equal(&"idle")

	runner.simulate_action_press("left")
	await runner.await_input_processed()
	await runner.simulate_frames(10, 20)

	assert_that(player.state_machine._current_state).is_equal(player.walk_state)
	assert_that(player.sprite.animation).is_equal(&"walk")
	assert_bool(player.sprite.flip_h).is_true()
	assert_bool(player.velocity.x < 0.0).is_true()

	runner.simulate_action_release("left")
	await runner.await_input_processed()
	await runner.simulate_frames(10, 20)
	assert_that(player.state_machine._current_state).is_equal(player.idle_state)
	assert_that(player.sprite.animation).is_equal(&"idle")
	assert_bool(player.velocity.x == 0.0).is_true()

func test_primary_action_enters_basic_attack_and_starts_combo_timer() -> void:
	var runner := scene_runner(PLAYER_SCENE)
	var player := runner.scene() as Player

	runner.simulate_action_press("up")
	await runner.await_input_processed()
	runner.simulate_action_press("primary_action")
	await runner.await_input_processed()

	await runner.simulate_frames(10, 20)

	assert_that(player.state_machine._current_state).is_equal(player.basic_attack_state)
	assert_that(player.sprite.animation).is_equal(&"up_attack_1")
	assert_bool(player.basic_attack_state.combo_timer.is_stopped()).is_false()
	assert_bool(player.basic_attack_state.combo_flag).is_false()
	assert_that(player.velocity).is_equal(Vector2.ZERO)
	await _release_actions(runner, ["up", "primary_action"])


func test_basic_attack_timer_expiry_returns_to_idle_without_combo() -> void:
	var runner := scene_runner(PLAYER_SCENE)
	var player := runner.scene() as Player

	runner.simulate_action_press("primary_action")
	await runner.await_input_processed()

	await runner.simulate_frames(5, 20)

	assert_that(player.state_machine._current_state).is_equal(player.basic_attack_state)
	assert_that(player.sprite.animation).is_equal(&"side_attack_1")
	assert_bool(player.basic_attack_state.combo_timer.is_stopped()).is_false()

	await runner.simulate_frames(60, 20)

	assert_that(player.state_machine._current_state).is_equal(player.idle_state)
	assert_that(player.sprite.animation).is_equal(&"idle")
	assert_bool(player.basic_attack_state.combo_timer.is_stopped()).is_true()
	assert_bool(player.basic_attack_state.combo_flag).is_false()
	assert_that(player.velocity).is_equal(Vector2.ZERO)
	await _release_actions(runner, ["primary_action"])


#func test_primary_action_during_combo_window_transitions_to_combo_attack() -> void:
	#var runner := scene_runner(PLAYER_SCENE)
	#var player := runner.scene() as Player
#
	#runner.simulate_action_press("primary_action")
	#await runner.await_input_processed()
#
	#await runner.simulate_frames(5, 20)
#
	#assert_that(player.state_machine._current_state).is_equal(player.basic_attack_state)
#
	#runner.simulate_action_release("primary_action")
	#await runner.await_input_processed()
#
	#runner.simulate_action_press("primary_action")
	#await runner.await_input_processed()
#
	#await runner.simulate_frames(5, 20)
	#assert_bool(player.basic_attack_state.combo_flag).is_true()
#
	#await runner.simulate_frames(5, 20)
#
	#assert_that(player.state_machine._current_state).is_equal(player.combo_attack_state)
	#assert_that(player.sprite.animation).is_equal(&"side_attack_2")
	#assert_bool(player.sprite.is_playing()).is_true()
	#assert_bool(player.basic_attack_state.combo_flag).is_false()
	#assert_bool(player.basic_attack_state.combo_timer.is_stopped()).is_true()
	#assert_that(player.velocity).is_equal(Vector2.ZERO)
#
	#await runner.simulate_frames(60, 20)
	#assert_that(player.state_machine._current_state).is_equal(player.idle_state)
	#assert_that(player.sprite.animation).is_equal(&"idle")
	#await _release_actions(runner, ["primary_action"])


func _release_actions(runner: GdUnitSceneRunner, actions: Array[String]) -> void:
	for action in actions:
		runner.simulate_action_release(action)
	await runner.await_input_processed()
