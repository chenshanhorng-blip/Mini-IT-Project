extends Control

@onready var hp_bar = $HP_bar
@onready var hp_text = $HP_number

var stat: CharacterStat = null

func _ready():
	hp_bar.show_percentage = false

func setup(new_stat: CharacterStat) -> void:
	stat = new_stat
	print("HUD connected to:", stat.character_name)
	update_hp_bar()

func _process(_delta):
	if stat == null:
		return

	update_hp_bar()

func update_hp_bar() -> void:
	hp_bar.max_value = stat.current_max_health
	hp_bar.value = stat.health
	hp_text.text = str(stat.health) + " / " + str(stat.current_max_health)
