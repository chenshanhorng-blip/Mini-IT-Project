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
	# Remember to update the level name here for each level (e.g. "level3", "level4", etc.)
	CheckpointManager.reset_checkpoint("level3", P1_SPAWN)
	
	
	# Safely connect the exit button signal
	if exit_button != null:
		if not exit_button.pressed.is_connected(_on_button_pressed):
			exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide()
	else:
		print("❌ Error: could not find a node named $Button in this level scene!")
	
	# Loop through and connect diamond signals (with null checks and debug hints)
	var points = [$BlueDiamond1, $BlueDiamond2, $BlueDiamond3]
	
	for point in points:
		if point != null:
			print("💎 Diamond found and connected: ", point.name)
			if not point.collected.is_connected(_on_point_collected):
				point.collected.connect(_on_point_collected)
		else:
			print("⚠️ Warning: one of the diamond nodes listed in the script is missing! Check that the diamonds in the scene tree are named exactly BlueDiamond1, 2, 3")
	# Call ONCE after the loop — not inside it
	# Calling inside the loop spawns P2 once per diamond (3 times = 3 characters)
	_setup_multiplayer()

# Spawns Player 2 in multiplayer mode only. Called once from _ready(),
# outside the diamond-connection loop above — this fixes the earlier bug
# where Player 2 was being instantiated multiple times (once per diamond)
func _setup_multiplayer() -> void:
	if Global.game_mode != "multiplayer":
		return
	if Global.player2_character == null:
		print("Level1: no player2_character set — skipping P2 spawn")
		return
 
	player2_node = P2_SCENE.instantiate()
	player2_node.position = P2_SPAWN  # Set BEFORE add_child so _ready() saves correct start_position
	add_child(player2_node)
	print("Level1: Player 2 spawned at ", P2_SPAWN)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_menu:
			if pause_menu.has_method("hide_pause") and pause_menu.has_method("show_pause"):
				if pause_menu.visible:
					pause_menu.hide_pause()
				else:
					pause_menu.show_pause()
			else:
				# Fallback: toggle visibility directly (in case the pause menu script isn't attached)
				pause_menu.visible = !pause_menu.visible

func _on_point_collected() -> void:
	collected_count += 1
	print("🎯 Diamond collected! Progress: ", collected_count, " / ", total_points)
	if collected_count >= total_points:
		show_exit_button()

func show_exit_button() -> void:
	if exit_button:
		exit_button.show()
		print("🚪 Goal reached, exit button is now visible!")

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
