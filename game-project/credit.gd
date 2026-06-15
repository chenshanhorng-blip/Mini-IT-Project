extends Control

func _ready():
	$Panel/Back.pressed.connect(_on_back)

func _on_back():
	get_tree().change_scene_to_file("res://scene/UI/main_menu.tscn")
