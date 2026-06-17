extends Node2D

func _ready():
	$Button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scene_level & map/map.tscn")
