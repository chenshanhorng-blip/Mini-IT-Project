extends Control

@onready var skill1_button = $"HBoxContainer/skill1"
@onready var skill2_button = $"HBoxContainer/skill2"
@onready var ultimate_button = $"HBoxContainer/ultimate"

var stat: CharacterStat = null
var player_script = null

func _ready() -> void:
	print("Skill UI ready")

	stat = Global.player1_character

	if stat == null:
		print("Skill UI: stat is null")
	else:
		print("Skill UI using:", stat.character_name)

	skill1_button.pressed.connect(use_skill_1_button)
	skill2_button.pressed.connect(use_skill_2_button)
	ultimate_button.pressed.connect(use_ultimate_button)

	print("Skill buttons connected")


func use_skill_1_button() -> void:
	print("Skill 1 button pressed")

	if stat == null:
		print("No character stat")
		return

	SkillSystem.use_skill_1(stat)
	stat.print_stat()


func use_skill_2_button() -> void:
	print("Skill 2 button pressed")

	if stat == null:
		print("No character stat")
		return

	SkillSystem.use_skill_2(stat)
	stat.print_stat()


func use_ultimate_button() -> void:
	print("Ultimate button pressed")

	if stat == null:
		print("No character stat")
		return

	SkillSystem.use_ultimate(stat)
	stat.print_stat()
