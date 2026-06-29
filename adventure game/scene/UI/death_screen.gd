extends CanvasLayer

@onready var game_over = $GameOver

func _ready():
	hide()
	process_mode = PROCESS_MODE_ALWAYS  # ← 加上这行！让按钮在暂停时可用
	print("死亡画面已加载，准备就绪")

func show_death_screen():
	game_over.play()
	print("显示死亡画面")
	show()
	get_tree().paused = true

func hide_death_screen():
	print("隐藏死亡画面")
	hide()
	get_tree().paused = false

# 从检查点继续
func _on_continue_button_pressed():
	print(">>> 继续按钮被点击 <<<")
	hide_death_screen()
	if CheckpointManager:
		CheckpointManager.respawn_player()
	else:
		print("CheckpointManager 不存在，重新开始关卡")
		get_tree().reload_current_scene()

# 重新开始关卡
func _on_restart_button_pressed():
	print(">>> 重启按钮被点击 <<<")
	hide_death_screen()
	get_tree().reload_current_scene()
	if Global.player1_character != null:
		Global.player1_character.reset_stats()
		print("Player stats reset before restart")


# 返回地图
func _on_map_button_pressed():
	print(">>> 地图按钮被点击 <<<")
	hide_death_screen()
	get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
