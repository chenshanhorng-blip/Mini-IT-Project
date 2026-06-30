extends Node
 
var player1_character: CharacterStat = null
 
# --- Multiplayer ---
var player2_character: CharacterStat = null
var game_mode: String = "single"   
var player1_character_type: int = -1   
var player2_character_type: int = -1   
var player_scene: String = "res://scene_movement/player1_movement.tscn"
var player2_scene: String = "res://scene_movement/player2_movement.tscn"
var show_minimap: bool = true
var show_hints: bool = true
 
# ============================================================
# CURRENT SLOT
# ============================================================
var current_slot: int = 1
var slot_mode: String = "load"  # "load" = Continue, "save" = New Game
 
func get_save_path(slot: int) -> String:
	return "user://savegame_slot" + str(slot) + ".dat"
 
# ============================================================
# LEVEL UNLOCK SYSTEM
# ============================================================
var levels_unlocked = {
	"level1": true,
	"level2": false,
	"level3": false,
	"level4": false,
	"level5": false,
}
 
func unlock_next_level(completed_level: String):
	# Use the passed parameter, not the class variable current_level
	match completed_level:
		"level1": levels_unlocked["level2"] = true
		"level2": levels_unlocked["level3"] = true
		"level3": levels_unlocked["level4"] = true
		"level4": levels_unlocked["level5"] = true
	save_game()
	print("Unlocked next level after: ", completed_level)
 
# ============================================================
# SAVE / LOAD SYSTEM
# ============================================================
var current_level: String = "level1"
var unlocked_skills: Array = []
var reward_progress: Dictionary = {}
var saved_checkpoint: Vector2 = Vector2.ZERO
var saved_player_hp: int = 100
 
func save_game(player = null, slot: int = current_slot):
	var save_data = {
		"levels_unlocked": levels_unlocked,
		"current_level": current_level,
		"player_hp": saved_player_hp,
		"player_position_x": 0.0,
		"player_position_y": 0.0,
		"checkpoint_position_x": saved_checkpoint.x,
		"checkpoint_position_y": saved_checkpoint.y,
		"player_scene": player_scene,
		"unlocked_skills": unlocked_skills,
		"reward_progress": reward_progress,
		"save_timestamp": Time.get_datetime_string_from_system(),
		"game_version": "1.0",
		"game_mode": game_mode,
		"player1_character_type": player1_character_type, 
		"player2_character_type": player2_character_type,
		"player2_hp": player2_character.health if player2_character != null else 100,
		"player1_max_hp": player1_character.current_max_health if player1_character != null else 100,
		"player2_max_hp": player2_character.current_max_health if player2_character != null else 0,
	}
	if player != null:
		if player.stat != null:
			save_data["player_hp"] = player.stat.health
		else:
			save_data["player_hp"] = player.health
		save_data["player_position_x"] = player.global_position.x
		save_data["player_position_y"] = player.global_position.y
		
	var file = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	if file == null:
		print("ERROR: Cannot open save file!")
		return
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Game saved to slot ", slot)
 
func load_game(slot: int = current_slot) -> bool:
	current_slot = slot
	var path = get_save_path(slot)
	if not FileAccess.file_exists(path):
		print("No save file in slot ", slot)
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("ERROR: Cannot open save file!")
		return false
	var content = file.get_as_text()
	file.close()
	if content == "" or content == null:
		print("ERROR: Save file is empty or corrupted!")
		return false
	var data = JSON.parse_string(content)
	if data == null:
		print("ERROR: Save file is corrupted or incompatible!")
		return false
	if data.has("levels_unlocked"):
		levels_unlocked = data["levels_unlocked"]
	if data.has("current_level"):
		current_level = data["current_level"]
	if data.has("player_scene"):
		player_scene = data["player_scene"]
	if data.has("unlocked_skills"):
		unlocked_skills = data["unlocked_skills"]
	if data.has("reward_progress"):
		reward_progress = data["reward_progress"]
	if data.has("player_hp"):
		saved_player_hp = data["player_hp"]
	if data.has("game_mode"): 
		game_mode = data["game_mode"]
	if data.has("checkpoint_position_x") and data.has("checkpoint_position_y"):
			saved_checkpoint = Vector2(
				data["checkpoint_position_x"],
				data["checkpoint_position_y"]
		)
	if data.has("game_mode"):
		game_mode = data["game_mode"]
	if data.has("player1_character_type"):
		player1_character_type = data["player1_character_type"]
		if player1_character_type >= 0:
			player1_character = Create_Character.Create_Character(player1_character_type)
			print("Restored Player 1 character from save")
	if data.has("player2_character_type") and game_mode == "multiplayer":
		player2_character_type = data["player2_character_type"]
		if player2_character_type >= 0:
			player2_character = Create_Character.Create_Character(player2_character_type)
			print("Restored Player 2 character from save")
	print("Game loaded from slot ", slot) 
	return true
 
func has_save_file(slot: int = current_slot) -> bool:
	return FileAccess.file_exists(get_save_path(slot))
 
func get_slot_info(slot: int) -> Dictionary:
	var path = get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {"exists": false, "slot": slot}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false, "slot": slot}
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return {"exists": false, "slot": slot}
	return {
		"exists": true,
		"slot": slot,
		"current_level": data.get("current_level", "level1"),
		"timestamp": data.get("save_timestamp", "Unknown"),
		"player_hp": data.get("player_hp", 100),
		"player1_max_hp": data.get("player1_max_hp", 100),
		"player2_hp": data.get("player2_hp", 0),
		"player2_max_hp": data.get("player2_max_hp", 0),
		"game_mode": data.get("game_mode", "single"),
	}
 
func delete_save(slot: int = current_slot):
	var path = get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Slot ", slot, " deleted!")
