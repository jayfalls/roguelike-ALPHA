extends DefaultLight


## STATE CHANGES
func _on_TopDetection_body_entered(_body):
	sprite.z_index = 1

func _on_BottomDetection_body_entered(_body):
	sprite.z_index = 0
