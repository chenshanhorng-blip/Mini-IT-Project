extends Control

var mode: String = "load"

@onready var button_click_sound = $ButtonClickSound

func _ready():
	mode = Global.slot_mode
	print("Mode is: ", mode)
	if not $Back.pressed.is_connected(_on_back_pressed):
		$Back.pressed.connect(_on_back_pressed)
	_update_slots()

func _update_slots():
	for i in range(1, 4):
		var slot_info = Global.get_slot_info(i)
		var slot_button = get_node("Slot/Slot" + str(i))
		var slot_label = get_node("Slot/Slot" + str(i) + "Label")
		var delete_button = get_node("Slot/Delete" + str(i))
		if slot_info["exists"]:
			slot_label.text = "🎮 Slot " + str(i) + "\n" + \
				"📍 Level: " + slot_info["current_level"] + "\n" + \
				"❤️ HP: " + str(slot_info["player_hp"]) + "\n" + \
				"🕐 " + slot_info["timestamp"]
			slot_button.disabled = false
			delete_button.visible = true
		else:
			slot_label.text = "🎮 Slot " + str(i) + "\n➕ [Empty]"
			# In save mode, empty slots are ENABLED
			# In load mode, empty slots are DISABLED
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
		if Global.load_game(slot):
			Transition.fade_to_scene("res://scene_level_map/map.tscn")
	else:
		Global.current_slot = slot
		Global.delete_save(slot)
		Global.levels_unlocked = {
			"level1": true,
			"level2": false,
			"level3": false,
			"level4": false,
			"level5": false,
		}
		Global.current_level = "level1"
		Global.player1_character = null
		Global.player_scene = "res://scene_movement/player1_movement.tscn"
		Global.saved_player_hp = 100
		Global.saved_checkpoint = Vector2.ZERO
		Global.unlocked_skills = []
		Global.reward_progress = {}
		Transition.fade_to_scene("res://Boss-system/intro.tscn")

func _on_delete_pressed(slot: int):
	button_click_sound.play()
	Global.delete_save(slot)
	_update_slots()

func _on_back_pressed():
	button_click_sound.play()
	Transition.fade_to_scene("res://scene/UI/main_menu.tscn")
