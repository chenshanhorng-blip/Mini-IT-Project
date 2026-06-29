extends Node2D

var collected_count = 0
var total_points = 3
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu  # ← ADD THIS

func _ready():
	CheckpointManager.reset_checkpoint("level4", Vector2(39, 100))
	if not exit_button.pressed.connect(_on_button_pressed):
		exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide()
	
	var points = [$RedDiamond1, $RedDiamond2, $RedDiamond3]
	for point in points:
		if point:
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
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button():
	exit_button.show()

func _on_button_pressed():
	Global.unlock_next_level("level4")
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
