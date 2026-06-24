extends Node2D
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu
# 🌟 新增：反馈面板引用，路径跟 level2 一样的结构
# 💡 如果你的 level5.tscn 场景树里还没有拖进 FeedbackPanel，需要先把 feedback_system.tscn 实例化进来，
# 并确保外层节点改名叫 "FeedbackPanel"（跟 level2 一样的命名方式）
@onready var feedback_panel = $FeedbackPanel/CanvasLayer/FeedbackPanel

func _ready() -> void:
	# 设置关卡重置点
	CheckpointManager.reset_checkpoint("level5", Vector2(55, 532))
	
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
	# 1. 解锁下一关（最后一关的话这行其实可以留着，不影响）
	Global.unlock_next_level("level5")
	
	# 2. 🛠️ 临时修改：去掉 dont_ask_again 的判断，只要有面板就【强行弹出】！
	if feedback_panel != null:
		if not feedback_panel.feedback_closed.is_connected(_go_back_to_map):
			feedback_panel.feedback_closed.connect(_go_back_to_map)
		feedback_panel.show()
		print("📋 [测试强弹] 成功找到反馈面板，正在强制弹出...")
	else:
		print("❌ 警告：依然找不到反馈面板节点，请检查路径是否正确！")
		_go_back_to_map()

# 🌟 专门负责安全切回大地图的函数
func _go_back_to_map() -> void:
	print("🚪 正在离开 Level 5，返回关卡大地图...")
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
