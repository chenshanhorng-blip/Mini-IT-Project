extends Node2D
var collected_count = 0
var total_points = 3
var player2_node = null
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu
@onready var bgm_level_3 = $bgmlevel3
const REWARD_POPUP_SCENE = preload("res://princessgame/reward/reward_popup.tscn")
const P2_SCENE           = preload("res://scene_movement/player2_movement.tscn")
const P1_SPAWN = Vector2(398, 115)
const P2_SPAWN  = Vector2(460, 115)

func _ready() -> void:
	Global.current_level = "level3"
	# 🛠️ 记得根据你具体关卡的名字修改这里（比如 "level3", "level4" 等）
	CheckpointManager.reset_checkpoint("level3", P1_SPAWN)
	
	
	# 出口按钮连接安全验证
	if exit_button != null:
		if not exit_button.pressed.is_connected(_on_button_pressed):
			exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide()
	else:
		print("❌ 错误：在当前关卡场景中找不到名为 $Button 的节点！")
	
	# 🛠️ 核心调整：遍历和连接钻石信号（带防空检查与模糊查找提示）
	var points = [$BlueDiamond1, $BlueDiamond2, $BlueDiamond3]
	
	for point in points:
		if point != null:
			print("💎 成功找到并连接钻石: ", point.name)
			if not point.collected.is_connected(_on_point_collected):
				point.collected.connect(_on_point_collected)
		else:
			print("⚠️ 警告：关卡脚本中列出的某个钻石节点缺失了！请检查当前关卡树里的钻石名字是否严格叫做 BlueDiamond1, 2, 3")
	
	# ✅ 移到 for 循环外面，整个 _ready() 只执行一次，避免重复生成 Player 2
	_setup_multiplayer()

func _setup_multiplayer() -> void:
	if Global.game_mode != "multiplayer":
		return
	if Global.player2_character == null:
		print("Level3: no player2_character set — skipping P2 spawn")
		return
 
	player2_node = P2_SCENE.instantiate()
	player2_node.position = P2_SPAWN  # Set BEFORE add_child so _ready() saves correct start_position
	add_child(player2_node)
	print("Level3: Player 2 spawned at ", P2_SPAWN)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_menu:
			if pause_menu.has_method("hide_pause") and pause_menu.has_method("show_pause"):
				if pause_menu.visible:
					pause_menu.hide_pause()
				else:
					pause_menu.show_pause()
			else:
				# 备用原生显隐控制（万一暂停菜单脚本没挂载成功）
				pause_menu.visible = !pause_menu.visible

func _on_point_collected() -> void:
	collected_count += 1
	print("🎯 捡到钻石！当前进度: ", collected_count, " / ", total_points)
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button() -> void:
	if exit_button:
		exit_button.show()
		print("🚪 达成目标，通关按钮已显现！")

func _on_button_pressed() -> void:
	RewardSystem.give_level_reward("level3")
	Global.unlock_next_level("level3")
	Global.save_game(null, Global.current_slot)
	_show_reward_popup()

func _show_reward_popup() -> void:
	var reward_popup = REWARD_POPUP_SCENE.instantiate()
	add_child(reward_popup)
	reward_popup.on_continue_pressed = func():
		Transition.fade_to_scene("res://scene_level_map/map.tscn")
	reward_popup.show_reward(
		"level3",
		RewardSystem.get_base_reward("level3"),
		collected_count * 10,
		collected_count
	)
