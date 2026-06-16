extends Node2D

var collected_count = 0
var total_points = 3
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu  # ← ADD THIS

func _ready():
	# Reset checkpoint
	CheckpointManager.reset_checkpoint("level1", Vector2(13, 206))
	print("Checkpoint reset at (13, 206)")
	
	# Connect button
	if not exit_button.pressed.is_connected(_on_button_pressed):
		exit_button.pressed.connect(_on_button_pressed)
	exit_button.hide()
	
	var points = [$GreenDiamond1, $GreenDiamond2, $GreenDiamond3]
	for point in points:
		if not point.collected.is_connected(_on_point_collected):
			point.collected.connect(_on_point_collected)

# ← ADD THIS FUNCTION
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu.hide_pause()
		else:
			pause_menu.show_pause()

func _on_point_collected():
	collected_count += 1
	print("Collected! ", collected_count, " / ", total_points)
	if collected_count >= total_points:
		print("Level 1 Complete!")
		show_exit_button()

func show_exit_button():
	exit_button.show()

func _on_button_pressed():
	Global.unlock_next_level("level1")
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
