extends Control

var selected_character: CharacterStat
var is_selecting: bool = false

@onready var boar_button = $HBoxContainer/Boar_Princess_Button
@onready var knight_button = $HBoxContainer/Knight_Button

func _ready() -> void:
	print("Character Selection screen loaded")


func _input(event) -> void:
	if is_selecting:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position

		if boar_button.get_global_rect().has_point(mouse_pos):
			print("Boar Princess selected")
			is_selecting = true
			select_boarprincess()

		elif knight_button.get_global_rect().has_point(mouse_pos):
			print("Tea Egg Knight selected")
			is_selecting = true
			select_teaeggknight()


func select_boarprincess() -> void:
	var selected_character = Create_Character.Create_Character(
		Create_Character.CharacterType.BOAR_PRINCESS
	)

	Global.player1_character = selected_character

	print("SELECTED PRINCESS")
	print("Global character = ", Global.player1_character.character_name)

	get_tree().change_scene_to_file("res://princessgame/tutorial_system/tutorial.tscn")


func select_teaeggknight() -> void:
	var selected_character = Create_Character.Create_Character(
		Create_Character.CharacterType.TEA_EGG_KNIGHT
	)

	Global.player1_character = selected_character

	print("SELECTED KNIGHT")
	print("Global character = ", Global.player1_character.character_name)

	get_tree().change_scene_to_file("res://princessgame/tutorial_system/tutorial.tscn")
