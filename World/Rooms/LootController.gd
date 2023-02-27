extends YSort

signal cleared


# Outside Refs
onready var lootManager = RunManager.lootManager
var enemyController

# Child Nodes
var chests: Array


## DECLARATION
func _ready():
	yield(get_tree(), "idle_frame")
	chests = get_children()


## STATE CHANGES
# Allow loot to spawn
func unlock() -> void:
	for chest in chests:
		chest.unlock()
		chest.connect("opened", self, "cleared_check")

# Spawn loot, signalling completion
func cleared_check() -> void:
	var rarity_modifier: int = enemyController.rarity_modifier
	for chest in chests:
		chest.animationPlayer.play("Open")
		lootManager.generate_loot(0,rarity_modifier)
		spawn_loot(chest.global_position, lootManager.currentTable)
		chest.opened = true
	emit_signal("cleared")


## LOOT SPAWNING
# Spawn a signle loot item
func spawn_loot(location: Vector2, lootType: int, lootIndex: int = lootManager.chosen_index) -> Object:
	var loot = lootManager.itemScene.instance()
	loot.lootType_index = lootType
	loot.lootTable_index = lootIndex
	loot.global_position = location
	loot.spritePath = lootManager.tables[lootType].sprite_paths[lootIndex]
	add_child(loot)
	loot.connect("replace_self", self, "swap_loot")
	return loot

# Spawns three loot items
func spawn_three_loot(plug_position: Vector2) -> void:
	lootManager.generate_loot(0,0)
	var positionModifiers: Array = [-32, 0, 32]
	var lootItems_types: Array = lootManager.threeLootItems.keys()
	var lootItems_indexes: Array = lootManager.threeLootItems.values()
	for n in [0,1,2]:
		spawn_loot(plug_position + Vector2(positionModifiers[n], 0), lootItems_types[n], lootItems_indexes[n])

# Swap between two loot items, used for weapon drops
func swap_loot(weapon_index: int, item_position, item_spritePath: String, lootType_index) -> void:
	var loot = lootManager.itemScene.instance()
	loot.new_item = false
	loot.lootType_index = lootType_index
	loot.lootTable_index = weapon_index
	loot.global_position = item_position
	loot.spritePath = item_spritePath
	add_child(loot)
	loot.connect("replace_self", self, "swap_loot")
