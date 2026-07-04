extends Node

# REWARD SYSTEM — per-slot

var current_slot: int = -1  # -1 = not loaded yet

# Total coins collected across all levels
var total_coins: int = 0

# Coins earned per level
var level_coins: Dictionary = {
	"level1": 0,
	"level2": 0,
	"level3": 0,
	"level4": 0,
	"level5": 0
}

# Rewards unlocked
var rewards_unlocked: Dictionary = {
	"bronze_medal":  false,
	"silver_medal":  false,
	"gold_medal":    false,
	"diamond_medal": false,
	"champion":      false,
	"coin_100":      false,
	"coin_500":      false,
	"coin_1000":     false,
}

# Signals
signal coins_changed(new_total: int)
signal reward_unlocked(reward_name: String)
signal level_reward_earned(level_name: String, coins: int)


func _ready() -> void:
	# Don't auto-load on startup — wait until a slot is selected
	print("RewardSystem ready — waiting for slot selection")

# SLOT MANAGEMENT
# Call this whenever a slot is selected (load or new game)


func get_save_path(slot: int) -> String:
	return "user://reward_data_slot" + str(slot) + ".cfg"

# Switch to a different slot — loads that slot's reward data into memory
func switch_slot(slot: int) -> void:
	if current_slot == slot:
		return
	# Save current slot first if we have one
	if current_slot >= 1:
		save_data()
	current_slot = slot
	_reset_memory()
	load_data()
	print("RewardSystem switched to slot ", slot, " — coins:", total_coins)


# Clear in-memory data without touching the file
func _reset_memory() -> void:
	total_coins = 0
	for level in level_coins:
		level_coins[level] = 0
	for reward in rewards_unlocked:
		rewards_unlocked[reward] = false


# Delete reward data for a specific slot (called when save slot is deleted)
func delete_slot_data(slot: int) -> void:
	var path = get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("RewardSystem: slot ", slot, " reward data deleted")
	# If we're currently on that slot, reset memory too
	if current_slot == slot:
		_reset_memory()
		current_slot = -1
	coins_changed.emit(total_coins)


# ============================================================
# COINS
# ============================================================

func add_coins(amount: int, level_name: String = "") -> void:
	_ensure_slot_loaded()
	total_coins += amount

	if level_name != "" and level_coins.has(level_name):
		level_coins[level_name] += amount

	coins_changed.emit(total_coins)
	print("Coins added:", amount, " Total:", total_coins, " (slot ", current_slot, ")")

	check_coin_milestones()
	save_data()


# ============================================================
# LEVEL COMPLETE REWARD
# ============================================================

func give_level_reward(level_name: String) -> void:
	_ensure_slot_loaded()
	var base_reward = get_base_reward(level_name)
	add_coins(base_reward, level_name)
	level_reward_earned.emit(level_name, base_reward)
	print("Level reward given:", level_name, " Coins:", base_reward)

	match level_name:
		"level1": unlock_reward("bronze_medal")
		"level2": unlock_reward("silver_medal")
		"level3": unlock_reward("gold_medal")
		"level4": unlock_reward("diamond_medal")
		"level5": unlock_reward("champion")

	save_data()


func get_base_reward(level_name: String) -> int:
	match level_name:
		"level1": return 50
		"level2": return 100
		"level3": return 150
		"level4": return 200
		"level5": return 300
	return 50


# ============================================================
# MILESTONES
# ============================================================

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
		print("Reward unlocked:", reward_name, " (slot ", current_slot, ")")
		save_data()


# ============================================================
# SAVE / LOAD — per slot file
# ============================================================

func save_data() -> void:
	if current_slot < 1:
		print("RewardSystem: no slot selected, skipping save")
		return

	var config = ConfigFile.new()
	config.set_value("coins", "total", total_coins)

	for level in level_coins:
		config.set_value("level_coins", level, level_coins[level])

	for reward in rewards_unlocked:
		config.set_value("rewards", reward, rewards_unlocked[reward])

	config.save(get_save_path(current_slot))
	print("Reward data saved to slot ", current_slot)


func load_data() -> void:
	if current_slot < 1:
		print("RewardSystem: no slot selected, skipping load")
		return

	var config = ConfigFile.new()
	if config.load(get_save_path(current_slot)) != OK:
		print("No reward data for slot ", current_slot, " — starting fresh")
		_reset_memory()
		return

	total_coins = config.get_value("coins", "total", 0)

	for level in level_coins:
		level_coins[level] = config.get_value("level_coins", level, 0)

	for reward in rewards_unlocked:
		rewards_unlocked[reward] = config.get_value("rewards", reward, false)

	print("Reward data loaded from slot ", current_slot, " — coins:", total_coins)


# Full reset for current slot (called from gallery Reset button)
func reset_data() -> void:
	_reset_memory()
	save_data()
	coins_changed.emit(total_coins)
	print("Reward data reset for slot ", current_slot)


# Safety — if something calls add_coins before switch_slot, auto-use Global.current_slot
func _ensure_slot_loaded() -> void:
	if current_slot < 1 and Global.current_slot >= 1:
		switch_slot(Global.current_slot)
