extends Node2D
class_name DefaultLight

# Child Nodes
onready var light: Light2D = $Light2D
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var flickerTween: Tween = $FlickerTween

# Stats
var originalRange: float
var flickerRange: Vector2
var flickerChange: float = 0.02
var flickerRange_variation: float = 0.01
var flickerTime: float = 1.5
var flickerTime_variation: float = 0.4
var flickerDown: bool = false


## DECLARATION
func _ready():
	yield(get_tree(), "idle_frame")
	originalRange = light.energy
	flickerRange.x = originalRange - flickerChange
	flickerRange.y = originalRange + flickerChange
	flickerTween.interpolate_property(light, "energy", light.energy, flickerRange.x, flickerTime/2, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	flickerTween.start()


## FLICKER
func flicker() -> void:
	if flickerDown:
		flickerTween.interpolate_property(light, "energy", light.energy, flickerRange.x, flickerTime/2, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	else:
		flickerTween.interpolate_property(light, "energy", light.energy, flickerRange.y, flickerTime/2, Tween.TRANS_BOUNCE, Tween.EASE_IN)

func _on_FlickerTween_tween_completed(_object, _key):
	flickerRange.x = originalRange - rand_range(flickerChange - flickerRange_variation, flickerChange + flickerRange_variation)
	flickerRange.y = originalRange + rand_range(flickerChange - flickerRange_variation, flickerChange + flickerRange_variation)
	flickerTime = rand_range(flickerTime - flickerTime_variation, flickerTime + flickerTime_variation)
	if flickerDown:
		flickerDown = false
	else:
		flickerDown = true
	flicker()
