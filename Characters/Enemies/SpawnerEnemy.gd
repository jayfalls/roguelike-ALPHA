extends RangedWeaponEnemy
class_name SpawnerEnemy

enum SPAWN_TYPES {
	DIRECTED = 0,
	RANDOM = 1,
}

export(SPAWN_TYPES) var spawn_type: int = 0

func spawn() -> void:
	match spawn_type:
		SPAWN_TYPES.DIRECTED:
			pass
