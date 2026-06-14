extends Node2D

var collected_count = 0
var total_points = 3

@onready var exit_button = $Button

func _ready():
	# Try moving player higher (smaller Y = higher up in Godot)
	CheckpointManager.reset_checkpoint("level4", Vector2(13, 180))
	
	exit_button.pressed.connect(_on_button_pressed)
	exit_button.hide()
	
	var points = [$RedDiamond1, $RedDiamond2, $RedDiamond3]
	for point in points:
		if point: 
			point.collected.connect(_on_point_collected)

func _on_point_collected():
	collected_count += 1
	
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button():
	exit_button.show()

# level4 completion button script
func _on_button_pressed():
	Global.unlock_next_level("level4")
	get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
