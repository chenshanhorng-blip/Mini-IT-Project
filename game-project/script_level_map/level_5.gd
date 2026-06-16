extends Node2D

@onready var pause_menu = $PauseMenu  # ← ADD THIS

func _ready():
	$Button.visible = false
	$Button.pressed.connect(_on_button_pressed)
	$Boss.boss_defeated.connect(_on_boss_defeated)

# ← ADD THIS FUNCTION
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu.hide_pause()
		else:
			pause_menu.show_pause()

func _on_boss_defeated():
	$Button.visible = true

func _on_button_pressed():
	Global.unlock_next_level("level5")
	get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
