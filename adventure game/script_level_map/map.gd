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

	if Global.player1_character != null:
		Global.player1_character.reset_stats()
		print("Player 1 stats reset on map load")

	# Gallery button — safely connect if it exists in the scene
	var gallery_btn = get_node_or_null("GalleryButton")
	if gallery_btn != null:
		if not gallery_btn.pressed.is_connected(_on_gallery_pressed):
			gallery_btn.pressed.connect(_on_gallery_pressed)

	# Back to main menu button
	var back_btn = get_node_or_null("BackButton")
	if back_btn != null:
		if not back_btn.pressed.is_connected(_on_back_pressed):
			back_btn.pressed.connect(_on_back_pressed)

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
	# --- Pause menu toggle ---
	if event.is_action_pressed("ui_cancel"):
		if has_node("PauseMenu"):
			$PauseMenu.show_pause()
		return

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
					Transition.fade_to_scene(level_scenes[level_name])
				else:
					print(level_name, " is locked!")


func _on_gallery_pressed() -> void:
	Transition.fade_to_scene("res://princessgame/reward/reward_gallery.tscn")


func _on_back_pressed() -> void:
	Transition.fade_to_scene("res://scene/UI/main_menu.tscn")
