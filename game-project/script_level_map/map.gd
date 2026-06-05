extends Node2D

func _ready():
	print("Map script loaded")
	$TextureRect.pressed.connect(_on_level_1_pressed)
	$TextureRect2.pressed.connect(_on_level_2_pressed)
	$TextureRect3.pressed.connect(_on_level_3_pressed)
	$TextureRect4.pressed.connect(_on_level_4_pressed)
	$TextureRect5.pressed.connect(_on_level_5_pressed)

func _on_level_1_pressed():
	print("Button clicked!")
	get_tree().change_scene_to_file("res://scene_level_map/level1.tscn")

func _on_level_2_pressed():
	print("Button clicked!")
	get_tree().change_scene_to_file("res://scene_level_map/level2.tscn")

func _on_level_3_pressed():
	print("Button clicked!")
	get_tree().change_scene_to_file("res://scene_level_map/level3.tscn")

func _on_level_4_pressed():
	print("Button clicked!")
	get_tree().change_scene_to_file("res://scene_level_map/level4.tscn")

func _on_level_5_pressed():
	print("Button clicked!")
	get_tree().change_scene_to_file("res://scene_level_map/level5.tscn")
