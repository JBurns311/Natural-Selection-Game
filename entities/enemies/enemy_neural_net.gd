
class_name enemy_neural_net
extends RefCounted

const OUTPUT_COUNT := 5

# very simple "neural net" for now
# (1 input, no hidden layers, 5 outputs)
var weights := PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0])
var biases := PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0])

func choose_strategy(distance_input: float) -> int:
	
	# Score the strategies
	var input := clampf(distance_input, 0.0, 1.0)
	var scores := PackedFloat32Array()
	scores.resize(OUTPUT_COUNT)
	for index in range(OUTPUT_COUNT):
		scores[index] = weights[index] * input + biases[index]

	# Return highest-scoring strategy
	var best := 0
	for index in range(1, OUTPUT_COUNT):
		if scores[index] > scores[best]:
			best = index
	return best


# Make mutated copies of the network
func mutated_copy() -> enemy_neural_net:
	var child := enemy_neural_net.new()

	for index in range(OUTPUT_COUNT):
		child.weights[index] = weights[index] + randf_range(-0.8, 0.8)
		child.biases[index] = biases[index] + randf_range(-0.8, 0.8)

	return child
