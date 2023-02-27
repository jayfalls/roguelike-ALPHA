extends Node2D

# Child Nodes
var traps: Array


## DECLARATION
func _ready():
	yield(get_tree(), "idle_frame")
	traps = get_tree().get_nodes_in_group("Trap")


## STATE CHANGES
func arm() -> void:
	for trap in traps:
		trap.armed = true

func disarm() -> void:
	for trap in traps:
		trap.armed = false
