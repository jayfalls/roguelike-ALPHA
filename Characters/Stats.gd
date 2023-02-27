extends Node

signal staminaUnblocked
signal update_focus
signal update_max_health(updating)
signal update_max_shield(updating)
signal update_max_stamina
signal update_stamina(recovery_time, target_stamina, wait_time)


var parent: Character
var HUD: HUD
onready var stamina_tween: Tween = $StaminaTween
onready var stamina_timer: Timer = $StaminaTimer

# Stats
export(int) var MAXHEALTH = 16 setget update_maxHealth
export(int) var MAXSTAMINA = 10.0 setget update_maxStamina
export(int) var MAXSHIELD = 0 setget update_maxShield
export(int) var SHIELD = 0 setget update_shield
var health = MAXHEALTH setget update_health
var stamina = MAXSTAMINA setget update_stamina
var recovery_time: float
var target_stamina: int
var second_recovery: bool = false
var stamina_copy: float setget update_stamina_copy
var staminaUnblockPerc: float = 0.5
var maxFocus: int = 500
var focus: int = 480
var focus_increase_amount: int = 10
var ultimateCost: int = 10

# States
var stamina_blocked: bool = false setget stamina_blocked


## DECLARATION
func _ready():
	health = MAXHEALTH


## HEALTH
func update_maxHealth(input) -> void:
	var oldMax: int = MAXHEALTH
	MAXHEALTH = int(input)
	health += MAXHEALTH - oldMax
	emit_signal("update_max_health", true)

func update_health(input) -> void:
	health = clamp(input, 0, MAXHEALTH)


## SHIELD
func update_maxShield(input) -> void:
	var oldMax: int = MAXSHIELD
	MAXSHIELD = int(input)
	SHIELD += MAXSHIELD - oldMax
	emit_signal("update_max_shield", true)

func update_shield(input) -> void:
	SHIELD = clamp(input, -MAXHEALTH, MAXSHIELD)


## STAMINA
func update_maxStamina(input) -> void:
	var oldMax: int = MAXSTAMINA
	MAXSTAMINA = int(input)
	stamina += MAXSTAMINA - oldMax
	emit_signal("update_max_stamina")

func update_stamina(input) -> void:
	if input < stamina:
		HUD.update_stamina(input)
	if stamina == input:
		second_recovery = true
	else:
		second_recovery = false
	stamina = clamp(input,0, MAXSTAMINA)
	stamina_timer.stop()
	stamina_tween.stop_all()
	stamina_tween.remove_all()
	var difference: float = MAXSTAMINA - stamina
	var third_of_stamina: float = MAXSTAMINA * 0.3
	if stamina <= 0.9:
		self.stamina_blocked = true
		recovery_time = parent.stamina_wait
		target_stamina = MAXSTAMINA * staminaUnblockPerc
	elif second_recovery or stamina > third_of_stamina:
		recovery_time = range_lerp(difference, 0, MAXSTAMINA - third_of_stamina, 0, 1)
		target_stamina = MAXSTAMINA
	else:
		recovery_time = range_lerp(difference, 0, third_of_stamina, 0, 0.4)
		target_stamina = third_of_stamina
	#target_stamina += 0.1
	recovery_time /= parent.staminaRecovery_multiplier
	stamina_timer.wait_time = parent.stamina_wait
	if second_recovery:
		recover_stamina()
	else:
		stamina_timer.start()

func _on_StaminaTimer_timeout():
	recover_stamina()

func recover_stamina() -> void:
	stamina_tween.interpolate_property(self, "stamina_copy", stamina, target_stamina, recovery_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	stamina_tween.start()

func _on_StaminaTween_tween_step(object, key, elapsed, value):
	HUD.update_stamina(stamina_copy)

func update_stamina_copy(input) -> void:
	stamina_copy = input
	stamina = stamina_copy
	stamina = clamp(stamina,0, MAXSTAMINA)
	if stamina == MAXSTAMINA:
		return
	if stamina_blocked:
		if stamina > MAXSTAMINA * staminaUnblockPerc:
			self.stamina_blocked = false
	if stamina_copy == target_stamina:
		self.update_stamina(stamina)

func stamina_blocked(input) -> void:
	stamina_blocked = input
	parent.stamina_blocked = stamina_blocked
	if stamina_blocked:
		HUD.block_stamina()
		parent.state_popup.popup("Stamina Blocked", Color(1, 1, 1))
	else:
		HUD.unblock_stamina()

func update_focus(use: bool = false) -> void:
	if use:
		focus -= ultimateCost
	else:
		focus += focus_increase_amount
	emit_signal("update_focus")
