extends Area2D
class_name Hurtbox

signal invincibility_started
signal invincibility_ended

onready var timer = $InvincibilityTimer

var invincible = false setget set_invincible

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	if duration != 0:
		self.invincible = true
		timer.start(duration)

func _on_Hurtbox_invincibility_ended():
	set_deferred("monitoring", true)

func _on_Hurtbox_invincibility_started():
	set_deferred("monitoring", false)

func _on_InvincibilityTimer_timeout():
	self.invincible = false
