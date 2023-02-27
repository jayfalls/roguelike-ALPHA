extends Node2D

## Effects
const GrassEffect = preload("res://Effects/GrassEffect.tscn")


## STATE CHANGES
func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	var world = get_tree().current_scene
	world.add_child(grassEffect)
	grassEffect.global_position = global_position
