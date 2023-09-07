extends Control
class_name HUD


signal restart
signal choice_made(choice_number)


# VARIABLES
## Children
onready var pause_menu: VBoxContainer = $Middle/Pause
onready var restart_button: Button = $"%RestartButton"
onready var quit_button: Button = $"%QuitButton"

onready var healthContainer = $"%HealthContainer"
onready var healthRadial = healthContainer.get_child(0)
onready var healthTween = healthContainer.get_child(2)
onready var healthText = healthContainer.get_child(3).get_child(0)

onready var staminaContainer = $"%StaminaContainer"
onready var staminaRadial = staminaContainer.get_child(0)
onready var staminaTween = staminaContainer.get_child(2)
onready var staminaText = staminaContainer.get_child(3).get_child(0)

onready var shieldContainer = $"%ShieldContainer"
onready var shieldRadial = shieldContainer.get_child(0)
onready var shieldTween = shieldContainer.get_child(2)
onready var shieldText = shieldContainer.get_child(3).get_child(0)

onready var currencyContainer = $"%CurrencyUI"
onready var gemsText = currencyContainer.get_child(0).get_child(1)
onready var coinsText = currencyContainer.get_child(1).get_child(1)
onready var currencyTween = currencyContainer.get_child(2)

onready var ultimateIndicators = $"%UltimateIndicators"
onready var focusProgress = ultimateIndicators.get_child(0)
onready var activeIndicator = ultimateIndicators.get_child(1)

onready var choiceWindow = $"%ChoiceWindow"
onready var choiceWindow_buttons: Array = choiceWindow.get_children()

onready var animationPlayer = $AnimationPlayer
onready var animationPlayer_timer = $AnimationPlayer/Timer

onready var lootManager = RunManager.lootManager
onready var propertyManager = RunManager.propertyManager

## States
var selection_mode: bool = false
var HUD_active: bool = false
var paused: bool = false

## Stats
var staminaColor = Color(0.035294, 0.729412, 0.341176)
var staminaBlockedColor = Color(0.913725, 0.913725, 0.913725)
var gems: int
var coins: int

## References
onready var player: Character = get_tree().get_nodes_in_group("Player").pop_front()
var stats: Node setget set_stats
var player_items: Node setget set_items


# INITIALISATION
func _ready():
	yield(get_tree(), "idle_frame")
	animationPlayer.play("Inactive")


# STATS
func set_stats(input) -> void:
	stats = input
	player.connect("taken_damage", self, "update_health")
	player.connect("update_health", self, "increase_health")
	player.connect("taken_shielddamage", self, "update_shield")
	player.connect("update_shield", self, "increase_shield")
	stats.connect("update_focus", self, "update_focus")
	stats.connect("update_max_health", self, "increase_health")
	stats.connect("update_max_shield", self, "increase_shield")
	stats.connect("update_max_stamina", self, "increase_stamina")
	healthRadial.max_value = stats.MAXHEALTH
	healthRadial.value = stats.health
	healthText.text = str(int(stats.health))
	staminaRadial.max_value = stats.MAXSTAMINA
	staminaRadial.value = stats.stamina
	staminaText.text = str(int(stats.stamina))
	shieldRadial.max_value = stats.MAXSHIELD
	shieldRadial.value = stats.SHIELD
	shieldText.text = str(int(stats.SHIELD))

func set_items(input) -> void:
	player_items = input
	player_items.connect("update_gems", self, "update_gems")
	player_items.connect("update_coins", self, "update_coins")
	gems = player_items.gems
	gemsText.text = str(gems)
	coins = player_items.coins
	coinsText.text = str(coins)

func update_health() -> void:
	var difference: float = (healthRadial.value - stats.health) / 5
	healthTween.interpolate_property(healthRadial, "value", healthRadial.value, stats.health, difference, Tween.TRANS_SINE, Tween.EASE_OUT)
	healthTween.start()

func increase_health(increase_maxHealth: bool) -> void:
	var difference: float = 1
	if increase_maxHealth:
		healthRadial.max_value = stats.MAXHEALTH
	healthTween.interpolate_property(healthRadial, "value", healthRadial.value, stats.health, difference, Tween.TRANS_SINE, Tween.EASE_OUT)
	healthTween.start()

func _on_HealthTween_tween_step(_object, _key, _elapsed, value):
	healthText.text = str(int(value))

func increase_shield(increase_maxShield: bool) -> void:
	var difference: float = 1
	if increase_maxShield:
		shieldRadial.max_value = stats.MAXSHIELD
	shieldTween.interpolate_property(shieldRadial, "value", shieldRadial.value, stats.SHIELD, difference, Tween.TRANS_SINE, Tween.EASE_OUT)
	shieldTween.start()

func increase_stamina() -> void:
	var difference: float = 1
	staminaTween.remove_all()
	staminaRadial.max_value = stats.MAXSTAMINA
	staminaTween.interpolate_property(staminaRadial, "value", staminaRadial.value, stats.stamina, difference, Tween.TRANS_SINE, Tween.EASE_OUT)
	staminaTween.start()

func update_shield() -> void:
	var difference: float = (shieldRadial.value - stats.SHIELD) / 5
	shieldTween.interpolate_property(shieldRadial, "value", shieldRadial.value, stats.SHIELD, difference, Tween.TRANS_SINE, Tween.EASE_OUT)
	shieldTween.start()

func _on_ShieldTween_tween_step(_object, _key, _elapsed, value):
	shieldText.text = str(int(value))
	

func update_stamina(stamina: float) -> void:
	staminaRadial.value = int(stamina) # Converting to int gives more of a step like motion
	staminaText.text = str(int(stamina))

func block_stamina() -> void:
	staminaRadial.tint_progress = staminaBlockedColor

func unblock_stamina() -> void:
	staminaRadial.tint_progress = staminaColor

func _on_StaminaTween_tween_step(_object, _key, _elapsed, value):
	staminaText.text = str(int(value))

func update_gems() -> void:
	show_HUD()
	var modifier = (gems - player_items.gems) / 5
	var difference: float = sqrt(modifier * modifier)
	currencyTween.interpolate_property(self, "gems", gems, player_items.gems, difference, Tween.TRANS_SINE, Tween.EASE_OUT)
	currencyTween.start()

func update_coins() -> void:
	show_HUD()
	var modifier = (coins - player_items.coins) / 5
	var difference: float = sqrt(modifier * modifier)
	currencyTween.interpolate_property(self, "coins", coins, player_items.coins, difference, Tween.TRANS_SINE, Tween.EASE_OUT)
	currencyTween.start()

func _on_CurrencyTween_tween_step(_object, _key, _elapsed, _value):
	gemsText.text = str(int(gems))
	coinsText.text = str(int(coins))

func update_focus() -> void:
	focusProgress.value = stats.focus
	if stats.ultimateCost <= stats.focus:
		activeIndicator.value = 0
	else:
		activeIndicator.value = 1

# CHOICE WINDOW
func show_window() -> void:
	selection_mode = true
	player.paused = true
	var lootType_index = lootManager.optionsType_index
	var table = lootManager.tables[lootType_index]
	choiceWindow.visible = true
	var count: int = 0
	choiceWindow_buttons[0].grab_focus()
	choiceWindow_buttons[0].pressed = true
	for button in choiceWindow_buttons:
		var heading = button.get_child(0)
		var description = button.get_child(1)
		var values_text = button.get_child(2)
		var old_value = values_text.get_child(0)
		var new_value = values_text.get_child(2)
		var index: int = lootManager.lootOptions_indexes[count]
		heading.text = table.heading_names[index]
		var value = table.values[index]
		description.text = table.descriptions[index].replace("*", str(value))
		var values: Array = propertyManager.get_values(index)
		if values[1] == -1:
			values_text.visible = false
		else:
			values_text.visible = true
			old_value.text = str(values[0]) + values[2]
			new_value.text = str(values[1]) + values[2]
		
		count += 1


# HUD MANAGEMENT
func _input(event):
	if selection_mode == true:
		if Input.is_action_just_pressed("ui_select"):
			emit_signal("choice_made", choiceWindow.choice)
			show_HUD()
	elif Input.is_action_just_pressed("Pause"):
		pause()
	elif Input.is_action_just_pressed("ShowHUD"):
		animationPlayer_timer.stop()
		show_HUD()
	elif Input.is_action_just_released("ShowHUD"):
		animationPlayer_timer.start()


func pause() -> void:
	if paused and not player.dead:
		paused = false
		pause_menu.hide()
		get_tree().paused = false
		restart_button.release_focus()
	else:
		paused = true
		pause_menu.show()
		restart_button.grab_focus()
		if player.dead:
			get_tree().paused = false
		else:
			get_tree().paused = true

func _on_Timer_timeout():
	hide_HUD()

func show_HUD() -> void:
	if not HUD_active:
		HUD_active = true
		animationPlayer.play("FadeIn")
	else:
		animationPlayer.play("Active")

func hide_HUD():
	if HUD_active:
		HUD_active = false
		animationPlayer.play("FadeOut")
	else:
		animationPlayer.play("Inactive")

func _on_HUD_choice_made(choice_number):
	choiceWindow.visible = false
	propertyManager.update_property(lootManager.lootOptions_indexes[choice_number])
	player.paused = false
	selection_mode = false


# Pause Menu
func _on_RestartButton_pressed():
	emit_signal("restart")
	get_tree().paused = false
	queue_free()

func _on_QuitButton_pressed():
	get_tree().quit()
