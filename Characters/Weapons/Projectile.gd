extends KinematicBody2D
class_name Projectile


onready var sprite: AnimatedSprite = $AnimatedSprite
onready var hitbox: Hitbox = $Hitbox

export(int) var SPEED: int = 300
export(float) var EXPIRY_TIME: float = 2
var move_direction: Vector2
var velocity: Vector2

var tick_time: float = 0


func _ready():
	sprite.rotation_degrees = rad2deg(move_direction.angle()) + 90


func _physics_process(delta):
	velocity += move_direction * SPEED
	velocity = velocity.limit_length(SPEED)
	move_and_slide(velocity)
	
	tick_time += delta
	if tick_time > EXPIRY_TIME:
		queue_free()


func _on_Hitbox_area_entered(_area):
	queue_free()
