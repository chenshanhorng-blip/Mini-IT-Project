extends Control

func _ready():
	$Menu/NewGame.pressed.connect(_on_new_game)
	$Menu/Continue.pressed.connect(_on_continue)
	$Menu/Setting.pressed.connect(_on_settings)
	$Menu/Quit.pressed.connect(_on_quit)
	$Menu/Credit.pressed.connect(_on_credit_pressed)

	# Disable Continue if NO slots have saves
	var any_save = Global.has_save_file(1) or Global.has_save_file(2) or Global.has_save_file(3)
	if not any_save:
		$Menu/Continue.disabled = true

func _on_new_game():
	Global.slot_mode = "save"
	print("New Game — slot mode set to: ", Global.slot_mode)
	Transition.fade_to_scene("res://scene/UI/slot_select.tscn")

func _on_continue():
	Global.slot_mode = "load"
	print("Continue — slot mode set to: ", Global.slot_mode)
	Transition.fade_to_scene("res://scene/UI/slot_select.tscn")

func _on_settings():
	Transition.fade_to_scene("res://scene/UI/setting.tscn")

func _on_quit():
	get_tree().quit()

func _on_credit_pressed():
	Transition.fade_to_scene("res://scene/UI/credit.tscn")


func _on_new_game_pressed() -> void:
	pass # Replace with function body.


func _on_continue_pressed() -> void:
	pass # Replace with function body.


func _on_setting_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	pass # Replace with function body.
