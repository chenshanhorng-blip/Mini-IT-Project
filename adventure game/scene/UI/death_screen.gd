extends CanvasLayer

@onready var game_over = $GameOver

func _ready():
	hide()
	process_mode = PROCESS_MODE_ALWAYS  # allows buttons to still work while game is paused
	print("死亡画面已加载，准备就绪")

func show_death_screen():
	game_over.play()
	print("显示死亡画面")
	# Force-close any active dragon dialogue so it doesn't block the buttons
	# The dialogue sits on DialogueLayer and intercepts mouse clicks
	var dialogue_layer = get_tree().root.find_child("DialogueLayer", true, false)
	if dialogue_layer != null:
		for child in dialogue_layer.get_children():
			child.queue_free()
		print("Cleared dialogue before showing death screen")
	show()
	get_tree().paused = true

func hide_death_screen():
	print("隐藏死亡画面")
	hide()
	get_tree().paused = false

# Continue from last saved checkpoint
func _on_continue_button_pressed():
	print(">>> 继续按钮被点击 <<<")
	hide_death_screen()
	# Reset stats BEFORE respawning so player has full HP
	if Global.player1_character != null:
		Global.player1_character.reset_stats()
	if Global.player2_character != null:
		Global.player2_character.reset_stats()
	if CheckpointManager:
		CheckpointManager.respawn_player()
	else:
		get_tree().reload_current_scene()

# Restart the current level from the beginning
func _on_restart_button_pressed():
	print(">>> 重启按钮被点击 <<<")
	hide_death_screen()
	# Reset stats BEFORE reloading so new scene starts with full HP
	if Global.player1_character != null:
		Global.player1_character.reset_stats()
	if Global.player2_character != null:
		Global.player2_character.reset_stats()
	get_tree().reload_current_scene()

# Return to the level select map
func _on_map_button_pressed():
	print(">>> 地图按钮被点击 <<<")
	hide_death_screen()
	get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
