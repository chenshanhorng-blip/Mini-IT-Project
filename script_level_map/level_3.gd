extends Node2D

var collected_count = 0
var total_points = 3

@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu
<<<<<<< HEAD
@onready var bgm_level_3 = $bgmlevel3
=======
>>>>>>> bfa5809f37f3978beea1e15c6cfe180f2c411237

func _ready() -> void:
	# 🛠️ 记得根据你具体关卡的名字修改这里（比如 "level3", "level4" 等）
	CheckpointManager.reset_checkpoint("level3", Vector2(398,115))
	
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
	# 🛠️ 记得把这里的 "level3" 改成你当前新关卡的名字，以便解开下一关
	Global.unlock_next_level("level3")
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
