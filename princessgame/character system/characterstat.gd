extends Resource
class_name CharacterStat

signal health_changed(current_max_health:int,max_health:int)
signal health_depleted
#for player know role name and definition
@export var character_name:String="Character"
@export var role:String="none"
#the begin of the character stats
@export var base_max_health:int= 60
@export var base_attack:int= 20
@export var base_max_shield:int= 10 
@export var base_movement:int= 30 
var current_max_health:int
var current_attack:int
var current_max_shield:int
var current_movement:int
var health:int =0 
var shield:int=0
#the passive of character and the original stat boar princess when not use the ultimate
var passive_applied: bool = false
var ultimate_active: bool = false
var original_attack: int = 0
var original_max_health: int = 0
var original_movement: int = 0
var tea_passive_count: int = 0
var tea_passive_max_count: int = 5

#the cooldown for both character
var skill1_cooldown: float = 3.0
var skill2_cooldown: float = 5.0
var ultimate_cooldown: float = 10.0

var skill1_ready_time: float = 0.0
var skill2_ready_time: float = 0.0
var ultimate_ready_time: float = 0.0

var _true_base_max_health: int = -1
var _true_base_attack: int = -1
var _true_base_max_shield: int = -1
var _true_base_movement: int = -1

# Initialize character stats by copying base values to current values.
# Sets the character's health to maximum and emits a signal to update UI.
func setup_stats() -> void:
	# Save the true original base values the very first time this runs
	if _true_base_max_health == -1:
		_true_base_max_health = base_max_health
		_true_base_attack     = base_attack
		_true_base_max_shield = base_max_shield
		_true_base_movement   = base_movement
 
	current_max_health = base_max_health
	current_attack = base_attack
	current_max_shield = base_max_shield
	shield=current_max_shield
	health = current_max_health
	current_movement=base_movement
	
#heal system if player got pick up an item that can heal the health
func heal(amount: int) -> void:
	health += amount
	health = clamp(health, 0, current_max_health)
	health_changed.emit(health, current_max_health)
#make sure the character is dead if the health is 0
func is_dead()->bool:
	return health<=0
#reset the character stat and add full health to player ,and the passive skill will also reset 
func reset_stats() -> void:
	# Restore base_attack/health/shield/movement to their TRUE original
	# values first — undoes any permanent passive buffs (e.g. Tea Egg
	# Knight's base_attack += 5) before recalculating current_* stats
	if _true_base_max_health != -1:
		base_max_health = _true_base_max_health
		base_attack     = _true_base_attack
		base_max_shield = _true_base_max_shield
		base_movement   = _true_base_movement
 
	setup_stats()
	passive_applied = false
	tea_passive_count = 0
		# Reset ultimate state so it never carries over between scenes
	ultimate_active = false
	original_attack = 0
	original_max_health = 0
	original_movement = 0

	# Reset all skill cooldowns so tutorial cooldowns never carry into level1
	skill1_ready_time = 0.0
	skill2_ready_time = 0.0
	ultimate_ready_time = 0.0

#look the caharacter stat at system 	
func print_stat() -> void:
	print("—————character stat——————")
	print("Type of hero:", character_name)
	print("Role:", role)
	print("HP:", health, "/", current_max_health)
	print("Attack:", current_attack)
	print("Shield:", shield, "/", current_max_shield)
	print("Speed:", current_movement)


	
	
	
		
	
	
		

 
