extends Control

# =========================
# UI Node References
@onready var hp_bar = $HP_bar
@onready var hp_text = $HP_number

# Character Data
var stat: CharacterStat = null

# Setup HUD
func setup(new_stat: CharacterStat) -> void:
	stat = new_stat
	update_hp_bar()

# Update Every Frame
func _process(_delta):
	if stat == null:
		return

	update_hp_bar()

# Update HP Bar
func update_hp_bar() -> void:
	hp_bar.max_value = stat.current_max_health
	hp_bar.value = stat.health

	hp_text.text = str(stat.health) + " / " + str(stat.current_max_health)
