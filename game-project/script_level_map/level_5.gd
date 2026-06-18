extends Node2D

@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu

func _ready() -> void:
	# 设置关卡重置点
	CheckpointManager.reset_checkpoint("level5", Vector2(13, 206))
	
	# 通关按钮安全初始化
	if exit_button != null:
		if not exit_button.pressed.is_connected(_on_button_pressed):
			exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide() # 游戏开始时先隐藏通关按钮
		print("ℹ️ 提示：当前为测试模式。在游戏里按下【空格键】可以假装击败Boss，显示通关按钮。")
	else:
		print("❌ 错误：找不到名为 $Button 的通关按钮！")

func _input(event: InputEvent) -> void:
	# 1. 暂停菜单控制
	if event.is_action_pressed("ui_cancel"):
		if pause_menu:
			if pause_menu.visible:
				pause_menu.hide_pause()
			else:
				pause_menu.show_pause()

	# 2. 🛠️ 临时测试机制：在游戏里按下【空格键/Enter键】直接假装 Boss 被打败
	if event.is_action_pressed("ui_accept"):
		print("🤖 收到测试指令：假装 Boss 已被击败！")
		_on_boss_defeated()

# 当 Boss 被击败时（或者你按了空格测试时）触发
func _on_boss_defeated() -> void:
	if exit_button:
		exit_button.show()
		print("🚪 通关按钮已显现！你可以点击它前往下一关了。")

func _on_button_pressed() -> void:
	# 解锁 Level 5 并返回大地图
	Global.unlock_next_level("level5")
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
