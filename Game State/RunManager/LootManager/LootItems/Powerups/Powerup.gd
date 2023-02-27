extends LootItem

signal choice_assigned

var indexes: Array

func choice_loot() -> int:
	return 1

func assign_choice(choice_number: int) -> void:
	lootType_index = indexes[choice_number]
	emit_signal("choice_assigned")
