extends Node2D

var collected_count = 0
var total_points = 3
var player2_node = null
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu  # ← ADD THIS
@onready var bgmlevel4 = $bgmlevel4

const REWARD_POPUP_SCENE = preload("res://princessgame/reward/reward_popup.tscn")
const P2_SCENE           = preload("res://scene_movement/player2_movement.tscn")
const P2_SPAWN = Vector2(100,100)

func _ready():
	CheckpointManager.reset_checkpoint("level4", Vector2(39, 100))
	if not exit_button.pressed.connect(_on_button_pressed):
		exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide()
	
	var points = [$RedDiamond1, $RedDiamond2, $RedDiamond3]
	for point in points:
		if point:
			point.collected.connect(_on_point_collected)
	_setup_multiplayer()

func _setup_multiplayer() -> void:
	if Global.game_mode != "multiplayer":
		return
	if Global.player2_character == null:
		return
 
	player2_node = P2_SCENE.instantiate()
	player2_node.position = P2_SPAWN
	add_child(player2_node)
	print("Level3: Player 2 spawned at ", P2_SPAWN)

# ← ADD THIS FUNCTION
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu.hide_pause()
		else:
			pause_menu.show_pause()

func _on_point_collected():
	collected_count += 1
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button():
	exit_button.show()

func _on_button_pressed():
	Global.unlock_next_level("level4")
	Global.save_game(null, Global.current_slot)
	Transition.fade_to_scene("res://scene_level_map/map.tscn")
