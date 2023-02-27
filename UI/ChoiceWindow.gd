extends Panel

# States
var choice: int


## STATE CHANGES
func _on_Choice1_toggled(button_pressed):
	if button_pressed:
		choice = 0

func _on_Choice2_toggled(button_pressed):
	if button_pressed:
		choice = 1

func _on_Choice3_toggled(button_pressed):
	if button_pressed:
		choice = 2
