extends Node
class_name CombatSystem

static func take_damage(stat: CharacterStat, damage:int) -> void:
	if stat == null:
		return

	var final_damage = damage

	print("Incoming Damage:", damage)

	# Shield blocks damage first
	if stat.shield > 0:
		if final_damage <= stat.shield:
			stat.shield -= final_damage
			final_damage = 0
		else:
			final_damage -= stat.shield
			stat.shield = 0

	# If shield is not enough, HP takes damage
	if final_damage > 0:
		stat.health -= final_damage
		stat.health = clamp(stat.health, 0, stat.current_max_health)

	# If dead, emit death signal and stop here
	if stat.health <= 0:
		stat.health_changed.emit(stat.health, stat.current_max_health)
		stat.health_depleted.emit()

		print("HP:", stat.health, "/", stat.current_max_health)
		print("Shield:", stat.shield, "/", stat.current_max_shield)
		print("Character is dead")
		return

	# Passive only trigger if still alive
	SkillSystem.trigger_passive_when_damaged(stat)

	stat.health_changed.emit(stat.health, stat.current_max_health)

	print("HP:", stat.health, "/", stat.current_max_health)
	print("Shield:", stat.shield, "/", stat.current_max_shield)


static func basic_attack_1(attacker: CharacterStat) -> void:
	if attacker == null:
		return

	print(attacker.character_name, "uses Basic Attack")
	print("Damage:", attacker.current_attack)
