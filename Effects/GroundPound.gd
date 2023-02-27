extends Particles2D

func activate() -> void:
	visible = true
	$AnimationPlayer.play("Expand")

func _on_AnimationPlayer_animation_finished(_anim_name):
	visible = false
