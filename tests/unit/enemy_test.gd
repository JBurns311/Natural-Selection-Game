extends GdUnitTestSuite

const Neural_net = preload("res://entities/enemies/enemy_neural_net.gd")
const EnemyScript = preload("res://entities/enemies/enemy.gd")

func test_choose_strategy_uses_distance_to_score_outputs() -> void:
	var neural_net := Neural_net.new()
	neural_net.biases[EnemyScript.Strategy.DIRECT] = 0.25
	neural_net.weights[EnemyScript.Strategy.CIRCLE_RANGE] = 1.0

	assert_int(neural_net.choose_strategy(0.1)).is_equal(EnemyScript.Strategy.DIRECT)
	assert_int(neural_net.choose_strategy(0.8)).is_equal(EnemyScript.Strategy.CIRCLE_RANGE)

# Each output should be able to select its corresponding strategy
func test_choose_strategy_can_select_each_strategy() -> void:
	for strategy in range(Neural_net.OUTPUT_COUNT):
		var neural_net := Neural_net.new()
		neural_net.biases[strategy] = 1.0

		assert_int(neural_net.choose_strategy(0.5)).is_equal(strategy)

# Creating and changing a child network should leave the parent's values alone
func test_mutated_copy_does_not_change_parent() -> void:
	var neural_net := Neural_net.new()
	neural_net.weights[0] = 0.25
	neural_net.biases[0] = 0.5
	var original_weights := neural_net.weights.duplicate()
	var original_biases := neural_net.biases.duplicate()

	var child := neural_net.mutated_copy()
	child.weights[0] = 10.0
	child.biases[0] = 20.0

	for index in range(Neural_net.OUTPUT_COUNT):
		assert_float(neural_net.weights[index]).is_equal(original_weights[index])
		assert_float(neural_net.biases[index]).is_equal(original_biases[index])

# Fitness should reward hits landed and become negative when more hits are taken
func test_fitness_counts_hits_landed_minus_hits_taken() -> void:
	var enemy := EnemyScript.new()

	assert_int(enemy.fitness()).is_equal(0)
	enemy.record_hit_scored()
	enemy.record_hit_scored()
	enemy.hits_taken = 1
	assert_int(enemy.fitness()).is_equal(1)

	enemy.hits_taken = 3
	assert_int(enemy.fitness()).is_equal(-1)
	enemy.free()
