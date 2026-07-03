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

	print("===== LEVEL2 =====")
	print("game_mode =", Global.game_mode)
	print("player2 =", Global.player2_character)
	print("player2_type =", Global.player2_character_type)
	Global.current_level = "level2"

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
	print("===== MULTIPLAYER CHECK =====")
	print("Mode =", Global.game_mode)
	print("Player2 =", Global.player2_character)
	print("Player2 Type =", Global.player2_character_type)

	if Global.game_mode != "multiplayer":
		print("Not multiplayer")
		return

	if Global.player2_character == null:
		print("Player2 is NULL")
		return

	player2_node = P2_SCENE.instantiate()
	add_child(player2_node)
	player2_node.global_position = P2_SPAWN

	print("Player2 Spawned")

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
	RewardSystem.give_level_reward("level2")
	Global.unlock_next_level("level2")
	Global.save_game(null, Global.current_slot)
 
	# Flow: Feedback first → Reward Popup → Map
	if feedback_panel != null:
		if not feedback_panel.feedback_closed.is_connected(_on_feedback_closed):
			feedback_panel.feedback_closed.connect(_on_feedback_closed)
		feedback_panel.show()
	else:
		_show_reward_popup()
 
 
func _on_feedback_closed():
	_show_reward_popup()
 
 
func _show_reward_popup():
	var reward_popup = REWARD_POPUP_SCENE.instantiate()
	add_child(reward_popup)
	reward_popup.on_continue_pressed = func():
		_go_back_to_map()
	reward_popup.show_reward(
		"level2",
		RewardSystem.get_base_reward("level2"),
		collected_count * 10,
		collected_count
	)
 
 
func _go_back_to_map():
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
