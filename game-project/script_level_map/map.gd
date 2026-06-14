extends Node2D

# ============================================================
# MAP SCRIPT - LEVEL SELECT WITH UNLOCK SYSTEM
# ============================================================

var level_scenes = {
	"level1": "res://scene_level_map/level1.tscn",
	"level2": "res://scene_level_map/level2.tscn",
	"level3": "res://scene_level_map/level3.tscn",
	"level4": "res://scene_level_map/level4.tscn",
	"level5": "res://scene_level_map/level5.tscn",
}

var level_nodes = {}

func _ready():
	print("Map script loaded")
	
	level_nodes = {
		"level1": $TextureRect,
		"level2": $TextureRect2,
		"level3": $TextureRect3,
		"level4": $TextureRect4,
		"level5": $TextureRect5,
	}
	
	setup_map()

func setup_map():
	for level_name in level_nodes:
		var node = level_nodes[level_name]
		var is_unlocked = Global.levels_unlocked[level_name]
		
		if is_unlocked:
			# hide lock icon
			if node.has_node("LockIcon"):
				node.get_node("LockIcon").visible = false
			# pulsing glow on unlocked levels
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(node, "modulate", Color(1.2, 1.2, 0.8), 0.8)
			tween.tween_property(node, "modulate", Color.WHITE, 0.8)
		else:
			node.modulate = Color(0.3, 0.3, 0.3)
			# show lock icon
			if node.has_node("LockIcon"):
				node.get_node("LockIcon").visible = true

func _input(event):
	# hover effect
	if event is InputEventMouseMotion:
		for level_name in level_nodes:
			var node = level_nodes[level_name]
			if node.get_global_rect().has_point(event.position):
				if Global.levels_unlocked[level_name]:
					node.scale = Vector2(1.1, 1.1)  # bigger on hover
			else:
				node.scale = Vector2(1.0, 1.0)  # back to normal

	# click to enter level
	if event is InputEventMouseButton and event.pressed:
		for level_name in level_nodes:
			var node = level_nodes[level_name]
			if node.get_global_rect().has_point(event.position):
				if Global.levels_unlocked[level_name]:
					print("Going to: ", level_name)
					get_tree().change_scene_to_file(level_scenes[level_name])
				else:
					print(level_name, " is locked!")
