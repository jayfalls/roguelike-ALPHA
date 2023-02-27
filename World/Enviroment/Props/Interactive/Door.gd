extends Node2D

signal entered
signal passed_through
signal exited_room

# Child Nodes
# frame/lock
onready var frame = $Frame
onready var lock = $Lock
onready var animation_player = $AnimationPlayer
onready var animation_player_lock = $AnimationPlayerLock

# collision/detection
onready var animation_player_collisions = $AnimationPlayerCollisions
onready var topDetection = $Collision/TopDetection
onready var passageDetection = $Collision/PassageDetection
onready var entryDetection = $Collision/EntryDetection
onready var passageCollision = $Collision/PassageCollision/CollisionShape2D
onready var entryCollision = $Collision/EntryCollision/CollisionShape2D
onready var doorCollision = $Collision/DoorCollision/CollisionShape2D

# misc
onready var openReverb = $SFX/OpenReverb
onready var marker = $MarkerLocation

# Stats
export(bool) var exit_door = false
export(bool) var FLIP_ENTRY = false


## DECLARATION
func _ready():
	if FLIP_ENTRY:
		frame.visible = true
	elif not exit_door:
		animation_player.play("Opened")
	else:
		frame.visible = false
		animation_player.play("Closed")
		animation_player_collisions.play("DoorBlocked")
		passageDetection.set_deferred("monitoring", false)
		lock.visible = true
		animation_player_lock.play("Floating")


## STATE CHANGES
# Handles entry function
func _on_PassageDetection_body_entered(_body):
	emit_signal("entered")
	if not FLIP_ENTRY:
		frame.visible = true
		if not exit_door:
			entry_close()
		else:
			emit_signal("exited_room")

func _on_TopDetection_body_entered(_body):
	if not FLIP_ENTRY:
		close_entrance()

func _on_EntryDetection_body_exited(_body):
	if FLIP_ENTRY:
		entryDetection.set_deferred("monitoring", false)
		frame.visible = false
		entry_close()
		close_entrance()

func entry_close() -> void:
	animation_player_collisions.play("EntryBlocked")
	animation_player.play("Close")
	passageDetection.set_deferred("monitoring", false)

func close_entrance() -> void:
	emit_signal("passed_through")
	if not exit_door:
		animation_player_collisions.play("FullyBlocked")
		topDetection.set_deferred("monitoring", false)

# Open a closed door
func open() -> void:
	animation_player_lock.play("Breaking")
	yield(get_tree().create_timer(2), "timeout")
	animation_player_lock.play("Still")
	yield(animation_player_lock, "animation_finished")
	lock.playing = true
	openReverb.play()
	yield(lock, "animation_finished")
	lock.visible = false
	animation_player.play("Open")
	yield(animation_player, "animation_finished")
	animation_player.play("Opened")

func opened() -> void:
	passageCollision.set_deferred("disabled", true)
	entryCollision.set_deferred("disabled", true)
	topDetection.set_deferred("monitoring", true)
	passageDetection.set_deferred("monitoring", true)

func door_blocked() -> void:
	passageCollision.set_deferred("disabled", false)

func entry_blocked() -> void:
	entryCollision.set_deferred("disabled", false)

func fully_blocked() -> void:
	doorCollision.set_deferred("disabled", false)
