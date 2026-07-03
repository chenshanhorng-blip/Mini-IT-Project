extends Control

@onready var button_click_sound = $ButtonClickSound

func _ready():
	# Use is_connected check to prevent double-connection on scene reload
	if not $Menu/NewGame.pressed.is_connected(_on_new_game):
		$Menu/NewGame.pressed.connect(_on_new_game)
	if not $Menu/Continue.pressed.is_connected(_on_continue):
		$Menu/Continue.pressed.connect(_on_continue)
	if not $Menu/Setting.pressed.is_connected(_on_settings):
		$Menu/Setting.pressed.connect(_on_settings)
	if not $Menu/Quit.pressed.is_connected(_on_quit):
		$Menu/Quit.pressed.connect(_on_quit)
	if not $Menu/Credit.pressed.is_connected(_on_credit_pressed):
		$Menu/Credit.pressed.connect(_on_credit_pressed)

	var gallery_btn = get_node_or_null("Menu/Gallery")
	if gallery_btn != null:
		if not gallery_btn.pressed.is_connected(_on_gallery_pressed):
			gallery_btn.pressed.connect(_on_gallery_pressed)

	# Disable Continue if NO slots have saves
	var any_save = Global.has_save_file(1) or Global.has_save_file(2) or Global.has_save_file(3)
	if not any_save:
		$Menu/Continue.disabled = true

func _on_new_game():
	button_click_sound.play()
	Global.slot_mode = "save"
	print("New Game — slot mode set to: ", Global.slot_mode)
	Transition.fade_to_scene("res://scene/UI/slot_select.tscn")

func _on_continue():
	button_click_sound.play()
	Global.slot_mode = "load"
	print("Continue — slot mode set to: ", Global.slot_mode)
	Transition.fade_to_scene("res://scene/UI/slot_select.tscn")

func _on_settings():
	Global.settings_return_scene = "main_menu"
	button_click_sound.play()
	Transition.fade_to_scene("res://scene/UI/setting.tscn")

func _on_quit():
	button_click_sound.play()
	get_tree().quit()

func _on_credit_pressed():
	button_click_sound.play()
	Transition.fade_to_scene("res://scene/UI/credit.tscn")


func _on_gallery_pressed():
	button_click_sound.play()
	Transition.fade_to_scene("res://princessgame/reward/reward_gallery.tscn")


func _on_new_game_pressed() -> void:
	pass # Replace with function body.


func _on_continue_pressed() -> void:
	pass # Replace with function body.


func _on_setting_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	pass # Replace with function body.
