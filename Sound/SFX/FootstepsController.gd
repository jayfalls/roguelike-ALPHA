extends Node

var counter: int = 0
var footsteps: Array

func _ready():
	yield(get_tree(), "idle_frame")
	for i in range(1,8):
		footsteps.append(get_node("Step" + str(i)))

func step() -> void:
	footsteps[counter].play()
	counter += 1
	if counter >= footsteps.size():
		counter = 0
