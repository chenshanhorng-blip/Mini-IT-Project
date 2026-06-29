extends Node
class_name skill_cooldown 
#Get Current Time and the process of the cooldown system calculation
static func get_time_now() -> float:
	return Time.get_ticks_msec() / 1000.0

# Check Skill Can Use
static func can_use_skill(stat: CharacterStat, skill_name: String) -> bool:
	if stat == null:
		return false

	var now = get_time_now()

	if skill_name == "skill1":
		return now >= stat.skill1_ready_time

	elif skill_name == "skill2":
		return now >= stat.skill2_ready_time

	elif skill_name == "ultimate":
		return now >= stat.ultimate_ready_time

	return false

#the process of the cooldown start
static func start_cooldown(stat: CharacterStat, skill_name: String) -> void:
	if stat == null:
		return

	var now = get_time_now()

	if skill_name == "skill1":
		stat.skill1_ready_time = now + stat.skill1_cooldown

	elif skill_name == "skill2":
		stat.skill2_ready_time = now + stat.skill2_cooldown

	elif skill_name == "ultimate":
		stat.ultimate_ready_time = now + stat.ultimate_cooldown

# get remaining skill's cooldown time
static func get_remaining_time(stat: CharacterStat, skill_name: String) -> float:
	if stat == null:
		return 0.0

	var now = get_time_now()
	var remaining = 0.0

	if skill_name == "skill1":
		remaining = stat.skill1_ready_time - now

	elif skill_name == "skill2":
		remaining = stat.skill2_ready_time - now

	elif skill_name == "ultimate":
		remaining = stat.ultimate_ready_time - now

	if remaining < 0:
		remaining = 0

	return remaining
