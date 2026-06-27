extends Node2D
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu
@onready var feedback_panel = $FeedbackPanel/CanvasLayer/FeedbackPanel
@onready var player = $Player1
var player2_node = null
var camera: Camera2D = null
var dragon_node = null
var boss_revealed = false

const REVEAL_DISTANCE = 700.0
const CLOSE_UP_ZOOM = Vector2(1.5, 1.5)   # 开场聚焦玩家
const REVEALED_ZOOM = Vector2(1.8, 1.8)   # 拉远看到龙

const P2_SCENE = preload("res://scene_movement/player2_movement.tscn")
const P2_SPAWN = Vector2(120, 532)
func _ready() -> void:
	CheckpointManager.reset_checkpoint("level5", Vector2(55, 532))

	camera = $Player1/Camera2D
	if camera:
		set_camera_zoom(CLOSE_UP_ZOOM, 2.0)   # 开场 zoom in 聚焦玩家
	else:
		print("❌ 警告：找不到 $Player1/Camera2D，请检查场景树里Camera2D的实际路径！")

	var bosses = get_tree().get_nodes_in_group("Boss")
	if bosses.size() > 0:
		dragon_node = bosses[0]
		if not dragon_node.boss_defeated.is_connected(_on_boss_defeated):
			dragon_node.boss_defeated.connect(_on_boss_defeated)
		print("✅ 已连接Boss死亡信号，击败龙后会自动显示通关按钮")
	else:
		print("❌ 警告：场景里找不到属于 Boss 群组的节点！请检查dragon.tscn是否加进Boss群组")

	if exit_button != null:
		if not exit_button.pressed.is_connected(_on_button_pressed):
			exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide()
		_setup_multiplayer()
 
	else:
		print("❌ 错误：找不到名为 $Button 的通关按钮！")
		
func _setup_multiplayer() -> void:
	if Global.game_mode != "multiplayer":
		return
	if Global.player2_character == null:
		return
 
	player2_node = P2_SCENE.instantiate()
	add_child(player2_node)
	player2_node.global_position = P2_SPAWN
	print("Level5: Player 2 spawned at ", P2_SPAWN)


func _process(delta: float) -> void:
	if boss_revealed or camera == null or dragon_node == null or not is_instance_valid(dragon_node):
		return

	var distance = player.global_position.distance_to(dragon_node.global_position)

	if distance <= REVEAL_DISTANCE:
		boss_revealed = true
		_reveal_dragon()

func _reveal_dragon() -> void:
	print("🐉 玩家靠近巨龙！镜头开始拉远...")
	set_camera_zoom(REVEALED_ZOOM, 1.5)

func set_camera_zoom(target_zoom: Vector2, duration: float = 1.0):
	if camera:
		var tween = create_tween()
		tween.tween_property(camera, "zoom", target_zoom, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_menu:
			if pause_menu.visible:
				pause_menu.hide_pause()
			else:
				pause_menu.show_pause()

func _on_boss_defeated() -> void:
	if exit_button:
		exit_button.show()
		print("🚪 龙被击败了！通关按钮已显现，可以点击它前往下一关了。")

func _on_button_pressed() -> void:
	Global.unlock_next_level("level5")
	if feedback_panel != null:
		if not feedback_panel.feedback_closed.is_connected(_go_back_to_map):
			feedback_panel.feedback_closed.connect(_go_back_to_map)
		feedback_panel.show()
		print("📋 成功找到反馈面板，正在弹出...")
	else:
		print("❌ 警告：依然找不到反馈面板节点，请检查路径是否正确！")
		_go_back_to_map()

func _go_back_to_map() -> void:
	print("🚪 正在离开 Level 5，返回关卡大地图...")
	Transition.fade_to_scene("res://Boss-system/ending.tscn")
