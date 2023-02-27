extends AimPivot

## DECLARATION
func _init():
	snap_aim = true


## TICK
func _physics_process(_delta: float) -> void:
	if parent.dead:
		return # Stop execution
	
	if parent.attacking:
		target_aim = true
	else:
		target_aim = false
	
	look()
