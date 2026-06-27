extends Control

func _ready():
	$Panel/Back.pressed.connect(_on_back)

func _on_back():
	Transition.fade_to_scene("res://scene/UI/main_menu.tscn")
