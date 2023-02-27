extends Node

signal update_gems
signal update_coins

# Stats
var gems: int = 0 setget update_gems
var coins: int = 0 setget update_coins


## STATE CHANGES
func update_gems(input) -> void:
	gems = input
	emit_signal("update_gems")

func update_coins(input) -> void:
	coins = input
	emit_signal("update_coins")
