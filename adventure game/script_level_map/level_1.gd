extends Node2D

var collected_count = 0
var total_points = 3
var reward_popup = null
var player2_node = null
@onready var exit_button = $Button
@onready var pause_menu = $PauseMenu  # ← ADD THIS
@onready var bgm_level_1 = $bgmlevel1

const REWARD_POPUP_SCENE = preload("res://princessgame/reward/reward_popup.tscn")
const P2_SCENE           = preload("res://scene_movement/player2_movement.tscn")
const P2_SPAWN = Vector2(18, 217)

func _ready():
	# Reset checkpoint
	CheckpointManager.reset_checkpoint("level1", Vector2(18, 217))
	print("Checkpoint reset at (18, 217)")
	
	# Connect button
	if not exit_button.pressed.is_connected(_on_button_pressed):
		exit_button.pressed.connect(_on_button_pressed)
	exit_button.hide()
	
	var points = [$GreenDiamond1, $GreenDiamond2, $GreenDiamond3]
	for point in points:
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

# ← ADD THIS FUNCTION
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu.hide_pause()
		else:
			pause_menu.show_pause()

func _on_point_collected():
	collected_count += 1
	RewardSystem.add_coins(10, "level1")
	print("Collected! ", collected_count, " / ", total_points)
	if collected_count >= total_points:
		print("Level 1 Complete!")
		show_exit_button()

func show_exit_button():
	exit_button.show()

func _on_button_pressed():
	Global.unlock_next_level("level1")
	_show_reward_popup()
	
func _show_reward_popup():
	reward_popup = REWARD_POPUP_SCENE.instantiate()
	add_child(reward_popup)
 
	# When player clicks Continue in popup → unlock next level → go to map
	reward_popup.on_continue_pressed = func():
		Global.unlock_next_level("level1")
		Transition.fade_to_scene("res://scene_level_map/map.tscn")
 
	reward_popup.show_reward(
		"level1",
		RewardSystem.get_base_reward("level1"),
		collected_count * 10,
		collected_count
	)
