extends Node2D

func _ready():
	$Button.visible = false
	$Button.pressed.connect(_on_button_pressed)
	$Boss.boss_defeated.connect(_on_boss_defeated)  # change $Boss to your boss node name

func _on_boss_defeated():
	$Button.visible = true

# level5 completion button script
func _on_button_pressed():
	Global.unlock_next_level("level5")
	get_tree().change_scene_to_file("res://scene_level_map/map.tscn")
