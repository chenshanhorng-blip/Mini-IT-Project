extends Node

var player1_character: CharacterStat = null
# Stores which player scene to spawn based on character selected
# "res://scene_movement/player1_movement.tscn" = Boar Princess
# "res://scene_movement/player2_movement.tscn" = Tea Egg Knight
var player_scene: String = "res://scene_movement/player1_movement.tscn"
var show_minimap: bool = true
var show_hints: bool = true
# ============================================================
# LEVEL UNLOCK SYSTEM
# ============================================================
var levels_unlocked = {
	"level1": true,   # always unlocked
	"level2": false,
	"level3": false,
	"level4": false,
	"level5": false,
}

func unlock_next_level(current_level: String):
	match current_level:
		"level1": levels_unlocked["level2"] = true
		"level2": levels_unlocked["level3"] = true
		"level3": levels_unlocked["level4"] = true
		"level4": levels_unlocked["level5"] = true
	save_game()  # auto save when level unlocked!
	print("Unlocked next level after: ", current_level)

# ============================================================
# SAVE / LOAD SYSTEM
# ============================================================
const SAVE_PATH = "user://savegame.dat"

# save/load related variables
var current_level: String = "level1"
var unlocked_skills: Array = []
var reward_progress: Dictionary = {}
var saved_checkpoint: Vector2 = Vector2.ZERO
var saved_player_hp: int = 100

func save_game(player = null):
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
	}

	# get live player data if player exists
	if player != null:
		save_data["player_hp"] = player.health
		save_data["player_position_x"] = player.global_position.x
		save_data["player_position_y"] = player.global_position.y

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("ERROR: Cannot open save file!")
		return
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Game saved successfully!")

func load_game() -> bool:
	# check file exists
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found!")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("ERROR: Cannot open save file!")
		return false

	var content = file.get_as_text()
	file.close()

	# error handling for corrupted file
	if content == "" or content == null:
		print("ERROR: Save file is empty or corrupted!")
		return false

	var data = JSON.parse_string(content)
	if data == null:
		print("ERROR: Save file is corrupted or incompatible!")
		return false

	# load all data back
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
	if data.has("checkpoint_position_x") and data.has("checkpoint_position_y"):
		saved_checkpoint = Vector2(
			data["checkpoint_position_x"],
			data["checkpoint_position_y"]
		)

	print("Game loaded successfully!")
	return true

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted!")
