extends Area2D
class_name Hitbox

signal focus

enum MODIFIERS {
	NONE,
	FIRE,
	WEAKNESS,
	CHAIN,
	SHIELD,
	STAGGER,
	LIFESTEAL
}

export(bool) var BOSS: bool = false

export(int) var damage = 4 setget update_damage
var actual_damage: int
var damage_modifier: float = 1 setget update_damage_modifier
export(bool) var CHAIN_HITBOX: bool = false
var chain_count: int = 0
var spread_distance: int = 1
export(bool) var AREA_DAMAGE = false
export(bool) var TRAP = false
export var KNOCKBACK_MULTIPLIER: float = 1
var non_character: bool = false
export var PLAYER_WEAPON_HITBOX = false
var player
export(MODIFIERS) var modifier: int = 0
export var modifier_value: int = 0
export(float) var STAGGER_DURATION: float = 1.5

var half_shieldDamage: bool = false

var staggerChance: int = 8 # In percentage
var aim_direction: Vector2 = Vector2.ZERO

func _ready():
	if PLAYER_WEAPON_HITBOX:
		half_shieldDamage = true
	if CHAIN_HITBOX:
		non_character = true
		damage_on()
		var spread_time: float = 0.8
		damage = damage / 3
		var tween: Tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(self, "scale", Vector2(0.01, 0.01), Vector2(spread_distance, spread_distance), spread_time, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.start()
		yield(get_tree().create_timer(spread_time), "timeout")
		queue_free()
	if TRAP:
		non_character = true

func damage_on() -> void:
	set_deferred("monitorable", true)

func damage_off() -> void:
	set_deferred("monitorable", false)

func playerFocus() -> void:
	emit_signal("focus")

func update_damage(input) -> void:
	damage = input * damage_modifier
	actual_damage = damage

func update_damage_modifier(input) -> void:
	damage = damage / damage_modifier
	damage_modifier = input
	self.damage = damage

func _on_Enemy_weak():
	damage /= 2

func _on_Enemy_unweak():
	damage *= 2

func _on_Player_weak():
	damage /= 2

func _on_Player_unweak():
	damage *= 2

func _on_Hitbox_body_entered(body):
	if CHAIN_HITBOX and body.NPC:
		chain_count += 1
		if chain_count == 3:
			queue_free()
