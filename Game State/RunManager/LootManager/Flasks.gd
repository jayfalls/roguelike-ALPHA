extends LootTable

var flask_types: Array
var flask_values: Array
var flask_sizes: Array

func _init():
	_add_property("Type", "flask_types")
	_add_property("Size", "flask_sizes")
	_add_property("Value", "flask_values")
