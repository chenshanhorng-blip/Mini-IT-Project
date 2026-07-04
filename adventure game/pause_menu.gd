extends CanvasLayer

func _ready():
	$Panel/VBoxContainer/Resume.pressed.connect(_on_resume)
	$Panel/VBoxContainer/SaveExit.pressed.connect(_on_save_exit)
	$Panel/VBoxContainer/Restart.pressed.connect(_on_restart)
	$Panel/VBoxContainer/Setting.pressed.connect(_on_settings)
	$Panel/VBoxContainer/Menu.pressed.connect(_on_main_menu)
	
	hide()

func show_pause():
	show()
	get_tree().paused = true

func hide_pause():
	hide()
	get_tree().paused = false

func _on_resume():
	hide_pause()

func _on_save_exit():
	var player = get_tree().get_first_node_in_group("player")
	Global.save_game(player)
	get_tree().paused = false
	get_tree().quit()

func _on_restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
	if Global.player1_character != null:
		Global.player1_character.reset_stats()
		print("Player stats reset before restart")

func _on_settings():
	Global.settings_return_scene = "pause"
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/UI/setting.tscn")

func _on_main_menu():
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/UI/main_menu.tscn")
