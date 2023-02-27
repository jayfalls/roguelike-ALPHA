extends VisibilityNotifier2D

var parent # Parent node

## States
export(bool) var IGNORE_OPTIMISATION: bool = false
var parent_set: bool = false


## STATE CHANGES
func _on_VisibilityOptimisation_screen_exited():
	if parent_set:
		parent.hide()

func _on_VisibilityOptimisation_screen_entered():
	if parent_set:
		parent.show()


## TICK
func _ready():
	if IGNORE_OPTIMISATION:
		return
	yield(get_tree(), "idle_frame")
	parent = get_parent()
	parent_set = true
	parent.visible = true
