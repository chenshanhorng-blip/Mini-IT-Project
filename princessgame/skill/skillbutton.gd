extends Control

@onready var skill1_button = $"HBoxContainer/skill 1"
@onready var skill2_button = $"HBoxContainer/skill 2"
@onready var ultimate_button = $"HBoxContainer/ultimate"

var stat: CharacterStat = null
var player_script = null

func _ready() -> void:
	stat = Global.player1_character
	
	skill1_button.pressed.connect(use_skill_1_button)
	skill2_button.pressed.connect(use_skill_2_button)
	ultimate_button.pressed.connect(use_ultimate_button)


func use_skill_1_button() -> void:
	if stat == null:
		return
	
	skill_system.use_skill_1(stat)
	stat.print_stat()


func use_skill_2_button() -> void:
	if stat == null:
		return
	
	skill_system.use_skill_2(stat)
	stat.print_stat()


func use_ultimate_button() -> void:
	if stat == null:
		return
	
	skill_system.use_ultimate(stat)
	stat.print_stat()
