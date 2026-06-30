extends Control

# ============================================================
# CHARACTER SELECTION
# Single mode:
#   Player 1 picks a character -> click it -> tutorial
#
# Multiplayer mode:
#   Player 1 picks first.
#   Player 2 picks second - CANNOT pick the same character
#   as Player 1 (that button becomes disabled/greyed out).
#   -> goes straight to the multiplayer tutorial
# ============================================================

var is_selecting: bool = false
var selecting_player: int = 1

var player1_pick: int = -1   # Create_Character.CharacterType value, -1 = none
var player2_pick: int = -1

@onready var boar_button   = $HBoxContainer/Boar_Princess_Button
@onready var knight_button = $HBoxContainer/Knight_Button
@onready var title_label   = get_node_or_null("TitleLabel")


func _ready() -> void:
	selecting_player = 1
	player1_pick = -1
	player2_pick = -1
	is_selecting = false
	update_title()
	update_button_states()
	print("Character Selection loaded — mode:", Global.game_mode)


func update_title() -> void:
	if title_label == null:
		return
	if Global.game_mode == "multiplayer":
		title_label.text = "Player " + str(selecting_player) + " — Choose Your Character"
	else:
		title_label.text = "Choose Your Character"


# Disable / grey out whichever character Player 1 already picked
# so Player 2 cannot pick the same one
func update_button_states() -> void:
	if Global.game_mode != "multiplayer" or selecting_player != 2:
		boar_button.disabled   = false
		knight_button.disabled = false
		boar_button.modulate    = Color.WHITE
		knight_button.modulate  = Color.WHITE
		return

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


func _input(event) -> void:
	if is_selecting:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position

		if boar_button.get_global_rect().has_point(mouse_pos) and not boar_button.disabled:
			_pick_character(Create_Character.CharacterType.BOAR_PRINCESS, "Boar Princess")

		elif knight_button.get_global_rect().has_point(mouse_pos) and not knight_button.disabled:
			_pick_character(Create_Character.CharacterType.TEA_EGG_KNIGHT, "Tea Egg Knight")


func _pick_character(type: int, char_name: String) -> void:
	print("Player", selecting_player, "selected:", char_name)

	if Global.game_mode == "multiplayer":
		_pick_character_multiplayer(type)
	else:
		_pick_character_single(type)


func _pick_character_single(type: int) -> void:
	is_selecting = true
	Global.player1_character = Create_Character.Create_Character(type)
	Global.player1_character_type = type
	print("SELECTED (single): ", Global.player1_character.character_name)
	Transition.fade_to_scene("res://princessgame/tutorial_system/tutorial.tscn")


func _pick_character_multiplayer(type: int) -> void:
	if selecting_player == 1:
		player1_pick = type
		selecting_player = 2
		update_title()
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

	Transition.fade_to_scene("res://princessgame/tutorial_system/tutorial_multiplayer.tscn")
