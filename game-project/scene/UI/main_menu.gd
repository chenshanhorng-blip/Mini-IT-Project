extends Control

func _ready():
	$Menu/NewGame.pressed.connect(_on_new_game)
	$Menu/Continue.pressed.connect(_on_continue)
	$Menu/Setting.pressed.connect(_on_settings)
	$Menu/Quit.pressed.connect(_on_quit)
	$Menu/Credit.pressed.connect(_on_credit_pressed)

func _on_new_game():
	Global.delete_save()
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
	get_tree().change_scene_to_file("res://princessgame/choose character/character selection.tscn")

func _on_continue():
	print("Save exists: ", Global.has_save_file())
	if Global.has_save_file():
		Global.load_game()
		get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
	else:
		print("No save file found!")

func _on_settings():
	get_tree().change_scene_to_file("res://scene/UI/setting.tscn")

func _on_quit():
	get_tree().quit()

func _on_credit_pressed():
	get_tree().change_scene_to_file("res://scene/UI/credit.tscn")
