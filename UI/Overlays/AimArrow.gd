extends Node2D

# Child Nodes
onready var animation_player = $AnimationPlayer


## DECLARATION
func _ready():
	animation_player.play("Blink")
