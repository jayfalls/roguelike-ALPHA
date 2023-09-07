extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns") # Creates an object with SQLite functionality

var controller_mode: bool = false
var keyboard_mode: bool = false

func _init() -> void:
	Input.add_joy_mapping("060000005e040000d102000003020000,Microsoft X-Box One pad,a:b0,b:b1,y:b3,x:b2,start:b7,back:b6,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:b12,dpleft:b14,dpdown:b13,dpright:b15,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,platform:Linux", true)
	randomize()
	centre_window()

func centre_window() -> void:
	var screen_size: Vector2 = OS.get_screen_size()
	var window_size: Vector2 = OS.get_window_size()
	
	OS.set_window_position(screen_size / 2 - window_size / 2)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Determine if a controller is being used
func _input(event: InputEvent) -> void:
	if controller_mode:
		if event is InputEventKey:
			controller_mode = false
	else:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			controller_mode = true
