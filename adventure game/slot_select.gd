extends Control

var mode: String = "load"

@onready var button_click_sound = $ButtonClickSound

func _ready():
	mode = Global.slot_mode
	print("SlotSelect mode: ", mode)
	if not $Back.pressed.is_connected(_on_back_pressed):
		$Back.pressed.connect(_on_back_pressed)

	# Load and display all save slots
	_update_slots()

func _update_slots():
	for i in range(1, 4):
		var slot_info = Global.get_slot_info(i)
		var slot_button = get_node("Slot/Slot" + str(i))
		var slot_label = get_node("Slot/Slot" + str(i) + "Label")
		var delete_button = get_node("Slot/Delete" + str(i))
		
		if slot_info["exists"]:
			var mode_text = "👤 Single"
			var p1_max = slot_info.get("player1_max_hp", 100)
			var hp_text = "❤️ HP: " + str(slot_info["player_hp"]) + " / " + str(p1_max)
			
			# Display different information for multiplayer saves
			if slot_info.get("game_mode", "single") == "multiplayer":
				mode_text = "👥 Multiplayer"
				var p2_max = slot_info.get("player2_max_hp", 0)
				hp_text = "❤️ P1 HP: " + str(slot_info["player_hp"]) + " / " + str(p1_max) + \
						  "\n❤️ P2 HP: " + str(slot_info.get("player2_hp", 0)) + " / " + str(p2_max)
			
			slot_label.text = "🎮 Slot " + str(i) + "\n" + \
							  "📍 Level: " + slot_info["current_level"] + "\n" + \
							  hp_text + "\n" + \
							  mode_text + "\n" + \
							  "🕐 " + slot_info["timestamp"]
			slot_button.disabled = false
			delete_button.visible = true
		else:
			slot_label.text = "🎮 Slot " + str(i) + "\n➕ [Empty]"
			if mode == "save":
				slot_button.disabled = false
			else:
				slot_button.disabled = true
			delete_button.visible = false
			
		if not slot_button.pressed.is_connected(_on_slot_pressed.bind(i)):
			slot_button.pressed.connect(_on_slot_pressed.bind(i))
		if not delete_button.pressed.is_connected(_on_delete_pressed.bind(i)):
			delete_button.pressed.connect(_on_delete_pressed.bind(i))

func _on_slot_pressed(slot: int):
	button_click_sound.play()
	
	Global.current_slot = slot

	if mode == "load":
		# Load the selected save slot and continue the game
		if Global.load_game(slot):
			RewardSystem.switch_slot(slot)

			print("Continuing slot ", slot, " | game_mode=", Global.game_mode,
				" | P2=", Global.player2_character != null)

			Transition.fade_to_scene("res://scene_level_map/map.tscn")
	else:
		# Start a new game by resetting the selected slot
		Global.delete_save(slot)
		RewardSystem.delete_slot_data(slot)
		RewardSystem.switch_slot(slot)

		Global.game_mode = "single"
		Global.player2_character = null
		Global.player2_character_type = -1
		Global.player1_character = null
		Global.player1_character_type = -1
		Global.levels_unlocked = {
			"level1": true,
			"level2": false,
			"level3": false,
			"level4": false,
			"level5": false,
		}
		Global.current_level = "level1"
		Global.player_scene = "res://scene_movement/player1_movement.tscn"
		Global.saved_player_hp = 100
		Global.saved_checkpoint = Vector2.ZERO
		Global.unlocked_skills = []
		Global.reward_progress = {}

		Transition.fade_to_scene("res://Boss-system/intro.tscn")

func _on_delete_pressed(slot: int):
	button_click_sound.play()

	# Delete the selected save slot
	Global.delete_save(slot)
	RewardSystem.delete_slot_data(slot)
	_update_slots()

func _on_back_pressed():
	button_click_sound.play()
	Transition.fade_to_scene("res://scene/UI/main_menu.tscn")
