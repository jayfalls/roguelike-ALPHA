extends Node

func angle_to_vector(a: float) -> Vector2: #Degrees
	var v: Vector2 = Vector2.ZERO
	v.x = cos(a)
	v.y = sin(a)
	return v

func rarity_generator(rarity_chance: int, rarity_guarantee: int) -> int:
	var rarity: int = _rollRarity()
	
	if rarity_guarantee in range(2,4):
		#var counter: int = 0
		while rarity < rarity_guarantee: #and counter < 5:
			rarity = _rollRarity()
			#counter += 1
		if rarity < rarity_guarantee:
			rarity = rarity_guarantee
	elif rarity_guarantee == 4:
		rarity = 4
	
	if rarity_chance > 0 and rarity != 4:
		var originalRarity: int = rarity
		var counter: int = 0
		while counter < rarity_chance:
			rarity = _rollRarity()
			counter += 1
		if rarity < originalRarity:
			rarity = originalRarity
	
	return rarity
# rarity_chance, how many times the calculation can be redone to try and achieve a higher rarity
# rarity_guarantee, always get a certain rarity or higher, 0 ignores effect
""" Rarity Values:
	1 - Common
	2 - Rare
	3 - Epic
	4 - Legendary 
"""
func _rollRarity() -> int:
	# The following variables determine the chance of each rarity
	var common = range(0,60)		# 60%
	var rare = range(60,87)			# 27%
	var epic = range(87,97)			# 10%
	var legendary = range(96,101)	# 4%
	var i = _randomRange100()
	var r: int
	if i in common:
		r = 1
	elif i in rare:
		r = 2
	elif i in epic:
		r = 3
	elif i in legendary:
		r = 4
	return r
func _randomRange100() -> int:
	var x: int = int(rand_range(0,100))
	return x

# Generates arandom number in a fixed range
func rand_range_modulo(limit_range: int, starting_range: int = 0) -> int:
	if limit_range > 0:
		var final_value: int = modulo(limit_range)
		while final_value < starting_range:
			final_value = modulo(limit_range)
		return final_value
	else:
		return 0

func modulo(limit_range: int) -> int:
	var modulo: int = limit_range + 1
	var random_number: int = int(rand_range(0, limit_range * 10000))
	var final_value: int = random_number % modulo
	return final_value


func randedge_around_vector(center: Vector2, distance: float) -> Vector2:
	var angle: int = rand_range_modulo(360)
	var direction: Vector2 = Vector2(cos(angle), sin(angle))
	var point: Vector2 = center + direction * distance
	return point

func randpoint_around_vector(center: Vector2, radius: float) -> Vector2:
	var point: Vector2
	point.x = rand_range(center.x - radius, center.x + radius)
	point.y = rand_range(center.y - radius, center.y + radius)
	return point
