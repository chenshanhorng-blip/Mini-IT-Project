extends Control
#state variable
var is_selecting: bool = false#let the player is on process of the selection
var selecting_player: int = 1#make sure the slection is player 1 or 2

var player1_pick: int = -1   # Create_Character.CharacterType value, -1 = none
var player2_pick: int = -1
#call the system ui to call the function in the scene
@onready var boar_button   = $HBoxContainer/Boar_Princess_Button
@onready var knight_button = $HBoxContainer/Knight_Button
@onready var title_label   = get_node_or_null("TitleLabel")
@onready var button_click_sound = $ButtonClickSound

func _ready() -> void:
	selecting_player = 1
	player1_pick = -1
	player2_pick = -1
	is_selecting = false
	update_title()#update the title when 
	update_button_states()# check the button status
	print("Character Selection loaded — mode:", Global.game_mode)

#the function update the tile 
func update_title() -> void:
	if title_label == null:
		print("TitleLabel not found!")
		return

	print("update_title called")
	print("Mode =", Global.game_mode)
	print("Selecting Player =", selecting_player)
# if the mode selection is multiplayer 
	if Global.game_mode == "multiplayer":
		title_label.visible = true
#it will list the player 1 first and after the player 1 select will 
#change the word to inform the player 2 click the buttton
		if selecting_player == 1:
			title_label.text = "PLAYER 1 CHOOSE"
		else:
			title_label.text = "PLAYER 2 CHOOSE"
	else:
		title_label.visible = false

# the button will become gray and cannot be click if the 
#player 1 have slelect the character he/she want
# So player 2 cannot select the same character 
func update_button_states() -> void:
	# if the mode is single ,the button is normal
	if Global.game_mode != "multiplayer" or selecting_player != 2:
		boar_button.disabled   = false
		knight_button.disabled = false
		boar_button.modulate    = Color.WHITE
		knight_button.modulate  = Color.WHITE
		return
# this is the process of the colour change after the player1 do the selection
	if player1_pick == Create_Character.CharacterType.BOAR_PRINCESS:
		boar_button.disabled   = true
		boar_button.modulate    = Color(0.4, 0.4, 0.4)
		knight_button.disabled = false
		knight_button.modulate  = Color.WHITE
	elif player1_pick == Create_Character.CharacterType.TEA_EGG_KNIGHT:
		knight_button.disabled = true
		knight_button.modulate   = Color(0.4, 0.4, 0.4)
		boar_button.disabled   = false
		boar_button.modulate     = Color.WHITE

# make suere the input have been detect or not
func _input(event) -> void:
	if is_selecting:# no action if already pick the character 
		return
# if the mouse left button is click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position
#if the player click the button of the boar princess will call the class name (file)
#for create the character and the state to the game
		if boar_button.get_global_rect().has_point(mouse_pos) and not boar_button.disabled:
			_pick_character(Create_Character.CharacterType.BOAR_PRINCESS, "Boar Princess")

		elif knight_button.get_global_rect().has_point(mouse_pos) and not knight_button.disabled:
			_pick_character(Create_Character.CharacterType.TEA_EGG_KNIGHT, "Tea Egg Knight")

# the fuctionn of the pick character
func _pick_character(type: int, char_name: String) -> void:
	button_click_sound.play()# if player click have the sound effect 
	print("Player", selecting_player, "selected:", char_name)

	if Global.game_mode == "multiplayer":
		_pick_character_multiplayer(type)
	else:
		_pick_character_single(type)

#the select character system for the single mode
func _pick_character_single(type: int) -> void:
	is_selecting = true#the player have select the character
	Global.player1_character = Create_Character.Create_Character(type)#create character that chosen by the player 
	print("SELECTED (single): ", Global.player1_character.character_name)
	button_click_sound.play()
	Transition.fade_to_scene("res://princessgame/tutorial_system/tutorial.tscn")
	#will transition to the tutorial system for the single mode

# the select character system for the multiplayer mode
func _pick_character_multiplayer(type: int) -> void:
	if selecting_player == 1:
		player1_pick = type
		selecting_player = 2
		update_title()# call the title for mention player 
		update_button_states()
		print("Now Player 2 selects...")
		return

	# selecting_player == 2
	player2_pick = type
	is_selecting = true

	Global.player1_character = Create_Character.Create_Character(player1_pick)
	Global.player2_character = Create_Character.Create_Character(player2_pick)

	Global.player1_character_type = player1_pick
	Global.player2_character_type = player2_pick


	print("Confirmed Player 1: ", Global.player1_character.character_name)
	print("Confirmed Player 2: ", Global.player2_character.character_name)

	button_click_sound.play()
	Transition.fade_to_scene("res://princessgame/tutorial_system/tutorial_multiplayer.tscn")
	 # go to the tutorial system for multiplayer mode
