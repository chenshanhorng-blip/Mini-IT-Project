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
const CLOSE_UP_ZOOM = Vector2(1.5, 1.5)   # Opening zoom — focused on player
const REVEALED_ZOOM = Vector2(1.8, 1.8)   # Wide zoom — reveals the dragon
const P2_SCENE = preload("res://scene_movement/player2_movement.tscn")
const P2_SPAWN = Vector2(120, 532)

func _ready() -> void:
	Global.current_level = "level5"
	CheckpointManager.reset_checkpoint("level5", Vector2(55, 532))
	camera = $Player1/Camera2D
	if camera:
		set_camera_zoom(CLOSE_UP_ZOOM, 2.0)   # Zoom in on the player at the start of the level
	else:
		print("❌ Warning: could not find $Player1/Camera2D — check the actual path of Camera2D in the scene tree!")
	
	# Find the dragon boss node (must belong to the "Boss" group) and 
	# connect its defeat signal so the exit button appears when it dies
	var bosses = get_tree().get_nodes_in_group("Boss")
	if bosses.size() > 0:
		dragon_node = bosses[0]
		if not dragon_node.boss_defeated.is_connected(_on_boss_defeated):
			dragon_node.boss_defeated.connect(_on_boss_defeated)
		print("✅ Boss defeated signal connected — exit button will appear automatically once the dragon is defeated")
	else:
		print("❌ Warning: no node belonging to the Boss group found in the scene! Check that dragon.tscn is added to the Boss group")
	
	if exit_button != null:
		if not exit_button.pressed.is_connected(_on_button_pressed):
			exit_button.pressed.connect(_on_button_pressed)
		exit_button.hide()
		_setup_multiplayer()
 
	else:
		print("❌ Error: could not find a node named $Button (exit button)!")

# Spawns Player 2 in multiplayer mode only. Called once from _ready()
func _setup_multiplayer() -> void:
	if Global.game_mode != "multiplayer":
		return
	if Global.player2_character == null:
		return
 
	player2_node = P2_SCENE.instantiate()
	add_child(player2_node)
	player2_node.global_position = P2_SPAWN
	print("Level5: Player 2 spawned at ", P2_SPAWN)

# Checks the player's distance to the dragon every frame.
# Once the player gets close enough, triggers the camera reveal (only once)
func _process(_delta: float) -> void:
	if boss_revealed or camera == null or dragon_node == null or not is_instance_valid(dragon_node):
		return
	var distance = player.global_position.distance_to(dragon_node.global_position)
	if distance <= REVEAL_DISTANCE:
		boss_revealed = true
		_reveal_dragon()

func _reveal_dragon() -> void:
	print("🐉 Player is approaching the dragon! Zooming camera out...")
	set_camera_zoom(REVEALED_ZOOM, 1.5)

# Smoothly animates the camera zoom to a target value over the given duration
func set_camera_zoom(target_zoom: Vector2, duration: float = 1.0):
	if camera:
		var tween = create_tween()
		tween.tween_property(camera, "zoom", target_zoom, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Toggle the pause menu when the player presses the cancel/escape action
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
		print("🚪 The dragon has been defeated! The exit button is now visible — click it to move on.")

func _on_button_pressed() -> void:
	RewardSystem.give_level_reward("level5")
	Global.unlock_next_level("level5")
	
	# Show the feedback panel first (if present); once closed, proceed to the ending scene
	if feedback_panel != null:
		if not feedback_panel.feedback_closed.is_connected(_go_back_to_map):
			feedback_panel.feedback_closed.connect(_go_back_to_map)
		feedback_panel.show()
		print("📋 Feedback panel found successfully, showing it now...")
	else:
		print("❌ Warning: feedback panel node still not found, please check the path!")
		_go_back_to_map()

func _go_back_to_map() -> void:
	print("Game Completed!")
	# Delete this slot's save file
	Global.delete_save(Global.current_slot)
	# Delete this slot's reward data
	RewardSystem.delete_slot_data(Global.current_slot)
	Transition.fade_to_scene("res://Boss-system/ending.tscn")
