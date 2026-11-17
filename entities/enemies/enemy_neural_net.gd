class_name enemy_neural_net
extends RefCounted

# A single linear layer with one input (normalized distance) and three outputs.
# Each output has a weight and a bias. The highest score chooses the strategy.
var weights := Vector3.ZERO
var biases := Vector3.ZERO


func choose_strategy(distance_input: float) -> int:
	var scores := weights * clampf(distance_input, 0.0, 1.0) + biases
	var best := 0
	for index in range(1, 3):
		if scores[index] > scores[best]:
			best = index
	return best


func mutated_copy() -> enemy_neural_net:
	var child := enemy_neural_net.new()
	for index in range(3):
		child.weights[index] = weights[index] + randf_range(-0.8, 0.8)
		child.biases[index] = biases[index] + randf_range(-0.8, 0.8)
	return child
