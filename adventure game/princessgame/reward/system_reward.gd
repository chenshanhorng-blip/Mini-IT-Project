extends Node

# Save file path
const SAVE_PATH = "user://reward_data.cfg"

# Total coins collected across all levels
var total_coins: int = 0

# Coins earned per level (key = level name, value = coins)
var level_coins: Dictionary = {
	"level1": 0,
	"level2": 0,
	"level3": 0,
	"level4": 0,
	"level5": 0
}

# Rewards unlocked (key = reward name, value = bool)
var rewards_unlocked: Dictionary = {
	"bronze_medal":  false,   # Complete level 1
	"silver_medal":  false,   # Complete level 2
	"gold_medal":    false,   # Complete level 3
	"diamond_medal": false,   # Complete level 4
	"champion":      false,   # Complete level 5
	"coin_100":      false,   # Collect 100 coins total
	"coin_500":      false,   # Collect 500 coins total
	"coin_1000":     false,   # Collect 1000 coins total
}

# Signals
signal coins_changed(new_total: int)
signal reward_unlocked(reward_name: String)
signal level_reward_earned(level_name: String, coins: int)


func _ready() -> void:
	load_data()
	print("RewardSystem ready. Total coins:", total_coins)

# COINS

# Call this when player collects a diamond/coin in a level
func add_coins(amount: int, level_name: String = "") -> void:
	total_coins += amount

	if level_name != "":
		if level_coins.has(level_name):
			level_coins[level_name] += amount

	coins_changed.emit(total_coins)
	print("Coins added:", amount, " Total:", total_coins)

	# Check milestone rewards
	check_coin_milestones()
	save_data()



# LEVEL COMPLETE REWARD
# Call this when player finishes a level


func give_level_reward(level_name: String) -> void:
	var base_reward = get_base_reward(level_name)
	add_coins(base_reward, level_name)
	level_reward_earned.emit(level_name, base_reward)
	print("Level reward given:", level_name, " Coins:", base_reward)

	# Unlock medal for this level
	match level_name:
		"level1": unlock_reward("bronze_medal")
		"level2": unlock_reward("silver_medal")
		"level3": unlock_reward("gold_medal")
		"level4": unlock_reward("diamond_medal")
		"level5": unlock_reward("champion")

	save_data()


func get_base_reward(level_name: String) -> int:
	# Basic coins per level completion
	match level_name:
		"level1": return 50
		"level2": return 100
		"level3": return 150
		"level4": return 200
		"level5": return 300
	return 50



# MILESTONE REWARDS


func check_coin_milestones() -> void:
	if total_coins >= 100 and not rewards_unlocked["coin_100"]:
		unlock_reward("coin_100")
	if total_coins >= 500 and not rewards_unlocked["coin_500"]:
		unlock_reward("coin_500")
	if total_coins >= 1000 and not rewards_unlocked["coin_1000"]:
		unlock_reward("coin_1000")


func unlock_reward(reward_name: String) -> void:
	if rewards_unlocked.has(reward_name) and not rewards_unlocked[reward_name]:
		rewards_unlocked[reward_name] = true
		reward_unlocked.emit(reward_name)
		print("Reward unlocked:", reward_name)
		save_data()

# SAVE / LOAD

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("coins", "total", total_coins)

	for level in level_coins:
		config.set_value("level_coins", level, level_coins[level])

	for reward in rewards_unlocked:
		config.set_value("rewards", reward, rewards_unlocked[reward])

	config.save(SAVE_PATH)
	print("Reward data saved.")


func load_data() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		print("No save data found — starting fresh.")
		return

	total_coins = config.get_value("coins", "total", 0)

	for level in level_coins:
		level_coins[level] = config.get_value("level_coins", level, 0)

	for reward in rewards_unlocked:
		rewards_unlocked[reward] = config.get_value("rewards", reward, false)

	print("Reward data loaded. Total coins:", total_coins)


func reset_data() -> void:
	total_coins = 0
	for level in level_coins:
		level_coins[level] = 0
	for reward in rewards_unlocked:
		rewards_unlocked[reward] = false
	save_data()
	print("Reward data reset.")
