extends Node

var player1_character: CharacterStat = null

# Stores which player scene to spawn based on character selected
# "res://scene_movement/player1_movement.tscn" = Boar Princess
# "res://scene_movement/player2_movement.tscn" = Tea Egg Knight
var player_scene: String = "res://scene_movement/player1_movement.tscn"

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
	print("Unlocked next level after: ", current_level)
