extends StaticBody2D

signal opened

onready var animationPlayer = $AnimationPlayer
onready var unlockSFX = $SFX/Unlock

var unlocked: bool = false
var opened: bool = false

func _ready():
	animationPlayer.play("Idle")

func unlock() -> void:
	unlocked = true
	unlockSFX.play()
	animationPlayer.play("Openable")

func _on_DetectionZone_body_entered(_body):
	if unlocked and not opened:
		emit_signal("opened")
