extends GdUnitTestSuite

const Neural_net = preload("res://entities/enemies/enemy_neural_net.gd")
const EnemyScript = preload("res://entities/enemies/enemy.gd")

func test_choose_strategy_uses_distance_to_score_outputs() -> void:
	var neural_net := Neural_net.new()
	neural_net.biases[EnemyScript.Strategy.DIRECT] = 0.25
	neural_net.weights[EnemyScript.Strategy.CIRCLE_RANGE] = 1.0

	assert_int(neural_net.choose_strategy(0.1)).is_equal(EnemyScript.Strategy.DIRECT)
	assert_int(neural_net.choose_strategy(0.8)).is_equal(EnemyScript.Strategy.CIRCLE_RANGE)
