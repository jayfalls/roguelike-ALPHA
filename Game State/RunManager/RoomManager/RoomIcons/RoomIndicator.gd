extends Node2D

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.play("Spawn")

func idle() -> void:
	animationPlayer.play("Idle")
