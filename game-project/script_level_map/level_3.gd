extends Node2D

var collected_count = 0
var total_points = 3

@onready var exit_button = $Button

func _ready():
	CheckpointManager.reset_checkpoint("level2", Vector2(13, 206))
	
	exit_button.pressed.connect(_on_button_pressed)
	exit_button.hide()
	
	var points = [$BlueDiamond1, $BlueDiamond2, $BlueDiamond3]
	for point in points:
		if point: 
			point.collected.connect(_on_point_collected)

func _on_point_collected():
	collected_count += 1
	
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button():
	exit_button.show()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
