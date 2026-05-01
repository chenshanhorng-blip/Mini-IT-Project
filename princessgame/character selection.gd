extends Control
var selected_character: CharacterStat
 
func _ready() :
	$HBoxContainer/Boar_Princess_Button.pressed.connect(select_boarprincess)
	$HBoxContainer/Knight_Button.pressed.connect(select_teaeggknight)
	
func select_boarprincess():
	selected_character = Create_Character.Create_Character(
		Create_Character.CharacterType.BOAR_PRINCESS
	)
	print("Selected princess")
	selected_character.print_stat()


func select_teaeggknight():
	selected_character = Create_Character.Create_Character(
		Create_Character.CharacterType.TEA_EGG_KNIGHT
	)
	print("Selected knight")
	selected_character.print_stat()
