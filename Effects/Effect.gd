extends Node2D
class_name Effect

signal finished

# Child Nodes
onready var animatedSprite = $AnimatedSprite


## DECLARATION
func _ready():
	animatedSprite.play("Effect")


## CLEAR INSTANCE
func _on_AnimatedSprite_animation_finished():
	emit_signal("finished")
	queue_free()
