extends Node
class_name StatePopup

onready var popup_text: PackedScene = preload("res://Default Classes/PopUpText.tscn")
var pops_to_handle: Array
var pop_to_handle_colors: Array
var waiting: bool = false
var dont_repeat: Array = ["No Weapon", "Not Enough Focus", "No Ultimate", "No Stamina"]


func popup(text: String, color: Color) -> void:
	if waiting:
		if text in dont_repeat:
			return
		pops_to_handle.append(text)
		pop_to_handle_colors.append(color)
		return
	var pop: PopupText = popup_text.instance()
	pop.text = text
	pop.color = color
	pop.spawned_from = get_parent()
	pop.connect("spaced", self, "waiting_done")
	waiting = true
	get_tree().root.add_child(pop)

func waiting_done(object: Object) -> void:
	object.disconnect("spaced", self, "waiting_done")
	waiting = false
	
	if pops_to_handle.empty():
		return
	popup(pops_to_handle.pop_front(),pop_to_handle_colors.pop_front())
