extends Node
class_name SkillSystem

static func apply_passive_on_start(stat: CharacterStat) -> void:
	if stat == null:
		return

	if stat.passive_applied == true:
		print("Passive already applied in this level")
		return

	if stat.character_name == "Boar Princess":
		stat.passive_applied = true
		print("Passive Activated: Princess Aura")
		print("Effect: Max Health +10")
		stat.current_max_health += 10
		stat.health += 10
		stat.health = clamp(stat.health, 0, stat.current_max_health)
		stat.health_changed.emit(stat.health, stat.current_max_health)

static func trigger_passive_when_damaged(stat: CharacterStat) -> void:

	if stat == null:
		return
	
	if stat.tea_passive_count >= stat.tea_passive_max_count:
		print("Tea Egg Knight passive reached max limit for this level")
		return
	
	if stat.character_name == "Tea Egg Knight":
		var chance = randi_range(1, 100)
#the percentage to active the passive skill
#if the chance is less than or is 10,will active this passive skill
		if chance >= 1 and chance <= 10:
				stat.health += 10
				stat.health = clamp(stat.health, 0, stat.current_max_health)
				stat.tea_passive_count += 1
				print("Passive Activated: Brewed for Battle - recovered 10 HP")


		elif chance >= 11 and chance <= 20:
			stat.base_attack += 5
			stat.shield = clamp(stat.base_attack, 0, stat.current_attack)
			stat.tea_passive_count += 1
			print("Passive Activated: Brewed for Battle - gained 5 shield")

static func use_skill_1(stat: CharacterStat) -> void:
	if stat == null:
		return
	print(stat.character_name, "used Skill 1")

	if stat.character_name == "Boar Princess":
		print("Boar Princess scold enemy")

	elif stat.character_name == "Tea Egg Knight":
		print("Tea Egg Knight uses shine shield")
		stat.shield+= 5
		stat.shield = clamp(stat.shield, 0, stat.current_max_shield)

static func use_skill_2(stat: CharacterStat) -> void:
	if stat == null:
		return

	print(stat.character_name, "used Skill 2")

	if stat.character_name == "Boar Princess":
		print("Boar Princess uses Swamp Guard")
		stat.shield += 5
		stat.shield = clamp(stat.shield, 0, stat.current_max_shield)
	elif stat.character_name == "Tea Egg Knight":
		print("Tea Egg Knight uses Verdant Leaf Storm")
		stat.health += 5
		stat.health= clamp(stat.health, 0,stat.current_max_health)

static func start_princess_ultimate(stat: CharacterStat) -> void:
	if stat == null:
		return

	if stat.ultimate_active == true:
		print("Princess Ultimate is already active")
		return

	stat.ultimate_active = true

	stat.original_attack = stat.current_attack
	stat.original_max_health = stat.current_max_health
	stat.original_movement = stat.current_movement

	print("Boar Princess used Ultimate")
	print("The Power of Love")

	stat.current_attack += 20
	stat.current_max_health += 20
	stat.health += 20
	stat.current_movement += 100

	stat.health = clamp(stat.health, 0, stat.current_max_health)
	stat.health_changed.emit(stat.health, stat.current_max_health)
	stat.print_stat()


static func end_princess_ultimate(stat: CharacterStat) -> void:
	if stat == null:
		return

	if stat.ultimate_active == false:
		return

	stat.ultimate_active = false

	print("Boar Princess Ultimate ended")

	stat.current_attack = stat.original_attack
	stat.current_max_health = stat.original_max_health
	stat.current_movement = stat.original_movement

	stat.health = clamp(stat.health, 0, stat.current_max_health)
	stat.health_changed.emit(stat.health, stat.current_max_health)
	stat.print_stat()


static func use_ultimate(stat: CharacterStat) -> void:
	if stat == null:
		return

	print(stat.character_name, "used Ultimate")

	if stat.character_name == "Tea Egg Knight":
		print("Tea Egg Knight uses Forbidden Thousand-Year Master Sauce")
		print("Effect: Causes damage to enemy")
		print("Ultimate Damage:", stat.current_attack + 30)

	stat.print_stat()


		
