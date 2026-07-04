extends Control

@onready var hp_bar  = $HP_bar
@onready var hp_text = $HP_number

var stat: CharacterStat = null
var _owner_name: String = ""


func _ready():
	hp_bar.show_percentage = false
	# Don't read any stat until setup() is explicitly called —
	# prevents accidentally reading Global.player1_character
	stat = null


func setup(new_stat: CharacterStat) -> void:
	if new_stat == null:
		push_error("player_hpbar.setup() called with null stat!")
		return
	stat = new_stat
	_owner_name = stat.character_name
	print("HUD connected to:", stat.character_name, " object_id:", stat.get_instance_id())
	update_hp_bar()


func _process(_delta):
	if stat == null:
		return
	update_hp_bar()

#the function to update the hp bar 
func update_hp_bar() -> void:
	if stat == null:
		return
	hp_bar.max_value = stat.current_max_health
	hp_bar.value     = stat.health
	hp_text.text     = str(stat.health) + " / " + str(stat.current_max_health)
