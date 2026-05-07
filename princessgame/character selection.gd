extends Control
var selected_character: CharacterStat
 
func _ready() :
	$HBoxContainer/Boar_Princess_Button.pressed.connect(select_boarprincess)
	$HBoxContainer/Knight_Button.pressed.connect(select_teaeggknight)
	
func select_boarprincess():
	selected_character = Create_Character.Create_Character(
		Create_Character.CharacterType.BOAR_PRINCESS
	)
	Global.player1_character=selected_character
	print("Selected princess")
	selected_character.print_stat()
	get_tree().change_scene_to_file("res://scene_movement/player1_movement.tscn")

func select_teaeggknight():
	selected_character = Create_Character.Create_Character(
		Create_Character.CharacterType.TEA_EGG_KNIGHT
	)
	Global.player1_character=selected_character
	print("Selected knight")
	selected_character.print_stat()
	get_tree().change_scene_to_file("res://scene_movement/player1_movement.tscn")
