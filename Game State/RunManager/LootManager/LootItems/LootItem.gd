extends Area2D
class_name LootItem

signal replace_self(weapon_index, item_position, lootType_index)
signal first_weapon

onready var sprite = $CollisionShape2D/Sprite
onready var animationPlayer = $AnimationPlayer
onready var label_animationPlayer = $CollisionShape2D/Interaction/AnimationPlayer

var spritePath: String = "."

var new_item: bool = true
# This loot item's type of loot
var lootType_index: int
# This item's position in its loot table
var lootTable_index: int
var interactable = false
var player: Character

func _process(_delta):
	if interactable:
		if Input.is_action_just_pressed("Interact"):
			_pick_loot()

func _ready():
	yield(get_tree(), "idle_frame")
	if spritePath != ".":
		sprite.texture = load(spritePath)
	if new_item:
		animationPlayer.play("Spawn")
		label_animationPlayer.play("Spawn")
		yield(animationPlayer, "animation_finished")
	animationPlayer.play("Idle")

func _on_LootItem_body_entered(body):
	player = body
	interactable = true
	label_animationPlayer.play("FadeIn")

func _on_LootItem_body_exited(_body):
	interactable = false
	label_animationPlayer.play("FadeOut")

func _pick_loot() -> void:
	interactable = false
	if lootType_index == 0 and not player.aim_pivot_melee.weapon.weapon == -1:
		emit_signal("replace_self", player.aim_pivot_melee.weapon.weapon, global_position, player.aim_pivot_melee.weapon.spritePath, lootType_index)
	elif lootType_index == 0:
		emit_signal("first_weapon")
	if lootType_index == 1 and not player.aim_pivot_ranged.weapon.weapon == -1:
		emit_signal("replace_self", player.aim_pivot_ranged.weapon.weapon, global_position, player.aim_pivot_ranged.weapon.spritePath.replace("_sheet.png",".png"), lootType_index)
	elif choice_loot() == 1:
		var HUD = UIManager.HUD
		HUD.connect("choice_made", self, "assign_choice")
		HUD.show_window()
		yield(self, "choice_assigned")
	player.update_loot(lootType_index, lootTable_index)
	queue_free()

func choice_loot() -> int:
	return 0

func assign_choice(choice_number: int) -> void:
	pass
