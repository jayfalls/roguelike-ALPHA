extends Position2D
class_name PopupText

signal spaced(self_object)

var spawned_from: Object

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var label : Label = $Node2D/Label
var text: String
var color: Color
onready var position_modifier = Vector2(rand_range(-2,2),0)


func _ready():
	label.text = text
	label.modulate = color
	
	animation_player.play("Load")

func _process(delta):
	if not is_instance_valid(spawned_from):
		return
	position = spawned_from.global_position + Vector2(0,-8) + position_modifier

func spaced() -> void:
	emit_signal("spaced", self)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
