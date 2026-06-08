extends Control

@onready var hp_bar = $HP_bar
@onready var hp_text = $HP_number

var stat: CharacterStat = null

func _ready():
	hp_bar.show_percentage = false
	
	# Try to connect from Global directly in case setup() wasn't called yet
	if Global.player1_character != null:
		setup(Global.player1_character)

func setup(new_stat: CharacterStat) -> void:
	stat = new_stat
	print("HUD connected to:", stat.character_name)
	
	# Connect the signal so HP bar updates instantly when HP changes
	if not stat.health_changed.is_connected(_on_health_changed):
		stat.health_changed.connect(_on_health_changed)
	
	# Set max and current values right away
	hp_bar.max_value = stat.current_max_health
	hp_bar.value = stat.health
	hp_text.text = str(stat.health) + " / " + str(stat.current_max_health)
	
	print("HP bar set: ", stat.health, " / ", stat.current_max_health)

func _on_health_changed(current_health: int, max_health: int) -> void:
	hp_bar.max_value = max_health
	hp_bar.value = current_health
	hp_text.text = str(current_health) + " / " + str(max_health)

func _process(_delta):
	# Fallback polling — only runs if signal was never connected
	if stat == null:
		if Global.player1_character != null:
			setup(Global.player1_character)
		return
	
	hp_bar.max_value = stat.current_max_health
	hp_bar.value = stat.health
	hp_text.text = str(stat.health) + " / " + str(stat.current_max_health)
