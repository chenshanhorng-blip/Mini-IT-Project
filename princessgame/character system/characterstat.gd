extends Resource
class_name CharacterStat

signal health_depleted
signal health_changed(curent_health:int,max_health:int)
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
# Initialize character stats by copying base values to current values.
# Sets the character's health to maximum and emits a signal to update UI.
func setup_stats() -> void:
	current_max_health = base_max_health
	current_attack = base_attack
	current_max_shield = base_max_shield
	shield=current_max_shield
	health = current_max_health
	health_changed.emit(health,current_max_health)
	
func take_damage_system(damage:int)->void:
#the shield will resist the damage when player take damage 
	var final_damage=damage
	if shield > 0:
		if final_damage <= shield:
			shield -= final_damage
			final_damage = 0
		else:
			final_damage-= shield
			shield = 0
#when the shield is 0 and the damage will decrease the health
	if final_damage > 0:
		health -= final_damage
		health = clamp(health, 0, current_max_health)
	health_changed.emit(health, current_max_health)

	if health <= 0:
		health_depleted.emit()
#heal system if player got pick up an item that can heal the health
func heal(amount: int) -> void:
	health += amount
	health = clamp(health, 0, current_max_health)
	health_changed.emit(health, current_max_health)
#make sure the character is dead if the health is 0
func is_dead()->bool:
	return health<=0
#reset the character stat and add full health to player 
func reset_stats() -> void:
	setup_stats()
func print_stat() ->void:
	print("—————character stat——————")
	print("Type of hero:",character_name)
	print("Role:",role)
	print("HP:",health,"/",base_max_health)
	print("Attack",base_attack)
	print("Shield:",shield,"/",base_max_shield)
	print("Speed:",base_movement)



	
	
	
		
	
	
		

 
