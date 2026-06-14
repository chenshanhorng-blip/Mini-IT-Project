extends Node2D

func _ready():
	# Reset checkpoint for Level 3
	CheckpointManager.reset_checkpoint("level3", Vector2(13, 206))
	
	# Set up exit button
	exit_button.pressed.connect(_on_button_pressed)
	exit_button.hide()
	
	# Connect all diamonds to the collection function
	var points = [$BlueDiamond1, $BlueDiamond2, $BlueDiamond3]
	for point in points:
		if point:
			print("Connecting diamond: ", point.name)
			point.collected.connect(_on_point_collected)

func _on_point_collected():
	collected_count += 1
	print("Diamond collected! Count: ", collected_count)
	
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button():
	exit_button.show()
# Level 3 completion - Unlocks next level and returns to map
func _on_button_pressed():
	Global.unlock_next_level("level3")
	get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
