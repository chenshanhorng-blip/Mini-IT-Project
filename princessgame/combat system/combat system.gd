extends Node
class_name CombatSystem

static func take_damage(stat: CharacterStat, damage:int) -> void:
	if stat == null:
		return
#the shield will resist the damage when player take damage 
	var final_damage = damage

	print("Incoming Damage:", damage)
	if stat.shield > 0:
		if final_damage <= stat.shield:
			stat.shield -= final_damage
			final_damage = 0
		else:
			final_damage-= stat.shield
			stat.shield = 0
#when the shield is 0 and the damage will decrease the health
	if final_damage > 0:
		stat.health -= final_damage
		stat.health = clamp(stat.health, 0, stat.current_max_health)
	stat.health_changed.emit(stat.health, stat.current_max_health)
	
	print("HP:", stat.health, "/", stat.current_max_health)
	print("Shield:", stat.shield, "/", stat.current_max_shield)
	
# Passive skill for tea egg knight after receive damage
	SkillSystem.trigger_passive_when_damaged(stat)

	stat.health_changed.emit(stat.health, stat.current_max_health)

	print("HP:", stat.health, "/", stat.current_max_health)
	print("Shield:", stat.shield, "/", stat.current_max_shield)

	if stat.health <= 0:
		stat.health_depleted.emit()


static func basic_attack_1(attacker: CharacterStat) -> void:
	if attacker == null:
		return

	print(attacker.character_name, "uses Basic Attack")
	print("Damage:", attacker.current_attack)
