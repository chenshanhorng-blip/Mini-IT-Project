extends Node2D

var collected_count = 0
var total_points = 3
@onready var exit_button = $ExitButton
@onready var pause_menu = $PauseMenu  # ← ADD THIS

func _ready():
	CheckpointManager.reset_checkpoint("level3", Vector2(13, 206))
	
	exit_button.pressed.connect(_on_button_pressed)
	exit_button.hide()
	
	var points = [$BlueDiamond1, $BlueDiamond2, $BlueDiamond3]
	for point in points:
		if point:
			print("Connecting diamond: ", point.name)
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
	print("Diamond collected! Count: ", collected_count)
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button():
	exit_button.show()

func _on_button_pressed():
	Global.unlock_next_level("level3")
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
