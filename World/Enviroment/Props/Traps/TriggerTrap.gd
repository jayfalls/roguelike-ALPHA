extends Node2D

# Child Nodes
onready var animationPlayer = $AnimationPlayer

# States
var armed: bool = false


## DECLARATION
func _ready():
	yield(get_tree(), "idle_frame")
	animationPlayer.play("Disengaged")


## STATE CHANGES
func _on_TriggerZone_body_entered(_body):
	if armed:
		animationPlayer.play("Trigger")
		yield(animationPlayer, "animation_finished")
		animationPlayer.play("Disengaged")
