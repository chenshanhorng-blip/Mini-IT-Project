extends Control


# MODE SELECTION — First screen before character selection
# Player picks Single Player or Multiplayer (local co-op)

#Find the button & sound and save it so we can use it later
@onready var single_button = $HBoxContainer/SinglePlayerButton
@onready var multi_button  = $HBoxContainer/MultiplayerButton
@onready var button_click_sound = $ButtonClickSound

func _ready() -> void:
	if not single_button.pressed.is_connected(_on_single_pressed):
		single_button.pressed.connect(_on_single_pressed)
	if not multi_button.pressed.is_connected(_on_multi_pressed):
		multi_button.pressed.connect(_on_multi_pressed)
	print("Mode Selection loaded")

#the function when the player choose the single mode
func _on_single_pressed() -> void:
	button_click_sound.play()#play the sound effect
	Global.game_mode = "single"# remember the mode is single
	Global.player1_character = null
	Global.player2_character = null#this is to clear out the old data 
	print("Mode: Single Player")
	Transition.fade_to_scene("res://princessgame/choose character/character selection.tscn")
# go to the scene of the character selection scene after slect the mode

func _on_multi_pressed() -> void:
	button_click_sound.play()# play the sound 
	Global.game_mode = "multiplayer"#remember the mode is the multiplayer mode
	Global.player1_character = null
	Global.player2_character = null# clear the old data
	print("Mode: Multiplayer")
	Transition.fade_to_scene("res://princessgame/choose character/character selection.tscn")
# go to the character selection scene after select the mode 
