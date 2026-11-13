# GdUnit generated TestSuite
class_name TestPersonTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/dummy_script.gd'


func test_full_name() -> void:
	var person = TestPerson.new("King", "Arthur")
	assert_str(person.full_name()).is_equal("King Arthur")
	person.free()
