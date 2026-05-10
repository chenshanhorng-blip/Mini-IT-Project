extends Node
class_name skill_system 

static func trigger_passive_when_damaged(stat: CharacterStat) -> void:
	
	if stat == null:
		return

	if stat.character_name == "Tea Egg Knight":
		var chance = randi_range(1, 100)
#the percentage to active the passive skill
#if the chance is less than or is 10,will active this passive skill
		if chance <= 10 or chance >=1:
			stat.health += 10
			stat.health = clamp(stat.health, 0, stat.current_max_health)
			print("Passive Activated: Brewed for Battle- recovered 5 HP")

		elif chance <= 20 or chance >=11:
			stat.shield += 5
			print("Passive Activated: Brewed for Battle - gained 3 shield")

static func use_skill_1(stat: CharacterStat) -> void:
	if stat == null:
		return
	print(stat.character_name, "used Skill 1")

	if stat.character_name == "Boar Princess":
		print("Boar Princess scold enemy")

	elif stat.character_name == "Tea Egg Knight":
		print("Tea Egg Knight uses shine shield")
		stat.shield+= 5


static func use_skill_2(stat: CharacterStat) -> void:
	if stat == null:
		return

	print(stat.character_name, "used Skill 2")

	if stat.character_name == "Boar Princess":
		print("Boar Princess uses Swamp Guard")
		stat.shield += 5

	elif stat.character_name == "Tea Egg Knight":
		print("Tea Egg Knight uses Verdant Leaf Storm")
		stat.health += 5


static func use_ultimate(stat: CharacterStat) -> void:
	if stat == null:
		return

	print(stat.character_name, "used Ultimate")

	if stat.character_name == "Boar Princess":
		print("The Power of love")
		stat.attack += 20
		stat.base_max_health+=20
		stat.current_movement += 100

	elif stat.character_name == "Tea Egg Knight":
		print("Forbidden Thousand-Year Master Sauce")
