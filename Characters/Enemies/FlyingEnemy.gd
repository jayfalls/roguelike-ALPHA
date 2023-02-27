extends Enemy
class_name FlyingEnemy

## TAKING DAMAGE
func flying_fall() -> void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(sprite, "position", sprite.position, Vector2.ZERO, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()
