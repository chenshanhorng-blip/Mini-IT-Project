#character stats for princess and knight
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
@export var base_shield:int= 10 
@export var movement:int= 30 

var current_max_health:int
var current_attack:int
var current_shield:int

var health:int =0 
# Initialize character stats by copying base values to current values.
# Sets the character's health to maximum and emits a signal to update UI.
func setup_stats() -> void:
	current_max_health = base_max_health
	current_attack = base_attack
	current_shield = base_shield
	health = current_max_health
	health_changed.emit(health,current_max_health)
	
func take_damage_system(damage:int)->void:
#the shield will resist the damage when player take damage 
	var final_damage=damage - current_shield
#when the shield is 0 and the damage will decrease the health
	if final_damage<1:
		final_damage=1
	health-=final_damage
	health=clamp(health,0,current_max_health)
	health_changed.emit(health,current_max_health)
#character death when the health is 0 or less tha 0
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



	
	
	
		
	
	
		

 
