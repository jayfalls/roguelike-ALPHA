extends Line2D

var trail_point: Position2D

var length: int = 30
var point: Vector2

func _process(_delta):
	if is_instance_valid(trail_point):
		if visible:
			add_points(trail_point.global_position)
	else:
		queue_free()

func add_points(pos: Vector2) -> void:
	global_position = Vector2(0,0)
	global_rotation = 0
	
	add_point(pos)
	while get_point_count() > length:
		remove_point(0)
