extends Control

# ============================================================
# MODE SELECTION — First screen before character selection
# Player picks Single Player or Multiplayer (local co-op)
# ============================================================

@onready var single_button = $HBoxContainer/SinglePlayerButton
@onready var multi_button  = $HBoxContainer/MultiplayerButton
@onready var button_click_sound = $ButtonClickSound

func _ready() -> void:
	if not single_button.pressed.is_connected(_on_single_pressed):
		single_button.pressed.connect(_on_single_pressed)
	if not multi_button.pressed.is_connected(_on_multi_pressed):
		multi_button.pressed.connect(_on_multi_pressed)
	print("Mode Selection loaded")


func _on_single_pressed() -> void:
	button_click_sound.play()
	Global.game_mode = "single"
	Global.player1_character = null
	Global.player2_character = null
	print("Mode: Single Player")
	Transition.fade_to_scene("res://princessgame/choose character/character selection.tscn")


func _on_multi_pressed() -> void:
	button_click_sound.play()
	Global.game_mode = "multiplayer"
	Global.player1_character = null
	Global.player2_character = null
	print("Mode: Multiplayer")
	Transition.fade_to_scene("res://princessgame/choose character/character selection.tscn")
