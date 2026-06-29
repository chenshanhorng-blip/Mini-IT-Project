extends Node2D

var collected_count = 0
var total_points = 3
var player2_node = null
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu
@onready var bgm_level_2 = $bgmlevel2

# 🌟 核心修复：穿过队友做的 Node2D 和 CanvasLayer，精准拿到真正挂脚本的 Panel 节点！
# 💡 注意：如果你的 level2 场景树里拉进来的节点名字叫 FeedbackPanel，就把下面这句改成：$FeedbackPanel/CanvasLayer/FeedbackPanel
@onready var feedback_panel = $FeedbackPanel/CanvasLayer/FeedbackPanel

const REWARD_POPUP_SCENE = preload("res://princessgame/reward/reward_popup.tscn")
const P2_SCENE           = preload("res://scene_movement/player2_movement.tscn")
const P2_SPAWN = Vector2(46, 113)


func _ready():
	CheckpointManager.reset_checkpoint("level2", Vector2(110, 113))
	
	if exit_button:
		# 安全连接通关按钮信号
		if not exit_button.pressed.is_connected(_on_button_pressed):
			exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide()
	
	# 连线紫色钻石信号
	var points = [$PurpleDiamond1, $PurpleDiamond2, $PurpleDiamond3]
	for point in points:
		if point:
			if not point.collected.is_connected(_on_point_collected):
				point.collected.connect(_on_point_collected)
	_setup_multiplayer()

func _setup_multiplayer() -> void:
	if Global.game_mode != "multiplayer":
		return
	if Global.player2_character == null:
		print("Level1: no player2_character set — skipping P2 spawn")
		return
 
	player2_node = P2_SCENE.instantiate()
	add_child(player2_node)
	player2_node.global_position = P2_SPAWN
	print("Level1: Player 2 spawned at ", P2_SPAWN)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if pause_menu:
			if pause_menu.visible:
				pause_menu.hide_pause()
			else:
				pause_menu.show_pause()

func _on_point_collected():
	collected_count += 1
	RewardSystem.add_coins(10, "level2")
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button():
	if exit_button:
		exit_button.show()

func _on_button_pressed():
	# 1. 正常解锁下一关
	Global.unlock_next_level("level2")
	
	# 2. 🛠️ 临时修改：去掉 dont_ask_again 的判断，只要有面板就【强行弹出】！
	if feedback_panel != null:
		# 连接关闭信号
		if not feedback_panel.feedback_closed.is_connected(_go_back_to_map):
			feedback_panel.feedback_closed.connect(_go_back_to_map)
		
		# 强制显示
		feedback_panel.show()
		print("📋 [测试强弹] 成功找到反馈面板，正在强制弹出...")
	else:
		# 只有当路径写错了、根本找不到这个节点时，才会走到这里
		print("❌ 警告：依然找不到反馈面板节点，请检查路径是否正确！")
		_go_back_to_map()

# 🌟 专门负责安全切回大地图的函数
func _go_back_to_map():
	print("🚪 正在离开 Level 2，返回关卡大地图...")
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
