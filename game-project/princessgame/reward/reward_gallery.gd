extends Control

# ============================================================
# REWARD GALLERY — expanded
# Shows:
# - Total coins with progress bar toward next milestone
# - Coins earned per level
# - All medals with lock/unlock status
# - Milestone rewards
# - Reset button
# ============================================================

@onready var total_coins_label   = $VBoxContainer/TotalCoinsLabel
@onready var milestone_label     = $VBoxContainer/MilestoneLabel
@onready var progress_bar        = $VBoxContainer/ProgressBar
@onready var medals_container    = $VBoxContainer/MedalsContainer
@onready var milestone_container = $VBoxContainer/MilestoneContainer
@onready var level_coins_label   = $VBoxContainer/LevelCoinsLabel
@onready var back_button         = $VBoxContainer/BackButton
@onready var reset_button        = $VBoxContainer/ResetButton


func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

	refresh_display()

	if not RewardSystem.reward_unlocked.is_connected(_on_reward_unlocked):
		RewardSystem.reward_unlocked.connect(_on_reward_unlocked)
	if not RewardSystem.coins_changed.is_connected(_on_coins_changed):
		RewardSystem.coins_changed.connect(_on_coins_changed)


# ============================================================
# REFRESH DISPLAY
# ============================================================

func refresh_display() -> void:
	update_coins_section()
	update_medals_section()
	update_milestone_section()
	update_level_coins_section()


# ============================================================
# COINS SECTION
# ============================================================

func update_coins_section() -> void:
	var total = RewardSystem.total_coins

	if total_coins_label:
		total_coins_label.text = "💰 Total Coins:  " + str(total)

	# Progress toward next milestone
	var next_milestone = get_next_milestone(total)
	var prev_milestone = get_prev_milestone(total)

	if milestone_label:
		if next_milestone > 0:
			milestone_label.text = "Next Milestone: " + str(next_milestone) + " coins  (" + str(next_milestone - total) + " to go)"
		else:
			milestone_label.text = "🏆 All coin milestones unlocked!"

	if progress_bar:
		if next_milestone > 0:
			progress_bar.max_value = next_milestone - prev_milestone
			progress_bar.value     = total - prev_milestone
		else:
			progress_bar.max_value = 1000
			progress_bar.value     = 1000


func get_next_milestone(coins: int) -> int:
	if coins < 100:  return 100
	if coins < 500:  return 500
	if coins < 1000: return 1000
	return 0  # All done


func get_prev_milestone(coins: int) -> int:
	if coins < 100:  return 0
	if coins < 500:  return 100
	if coins < 1000: return 500
	return 1000


# ============================================================
# MEDALS SECTION
# ============================================================

func update_medals_section() -> void:
	if medals_container == null:
		return

	var medal_data = [
		{"name": "bronze_medal",  "label": "Level 1",  "medal": "🥉 Bronze Medal"},
		{"name": "silver_medal",  "label": "Level 2",  "medal": "🥈 Silver Medal"},
		{"name": "gold_medal",    "label": "Level 3",  "medal": "🥇 Gold Medal"},
		{"name": "diamond_medal", "label": "Level 4",  "medal": "💎 Diamond Medal"},
		{"name": "champion",      "label": "Level 5",  "medal": "🏆 Champion"},
	]

	for child in medals_container.get_children():
		child.queue_free()

	for data in medal_data:
		var unlocked = RewardSystem.rewards_unlocked.get(data["name"], false)
		var label    = Label.new()

		if unlocked:
			label.text     = data["medal"] + "  —  " + data["label"] + "  ✅"
			label.modulate = Color.YELLOW
		else:
			label.text     = "🔒  " + data["label"] + "  —  Locked"
			label.modulate = Color(0.5, 0.5, 0.5)

		medals_container.add_child(label)


# ============================================================
# MILESTONE SECTION
# ============================================================

func update_milestone_section() -> void:
	if milestone_container == null:
		return

	var milestone_data = [
		{"name": "coin_100",  "label": "Coin Collector  —  Collect 100 coins"},
		{"name": "coin_500",  "label": "Treasure Hunter  —  Collect 500 coins"},
		{"name": "coin_1000", "label": "Coin Master  —  Collect 1000 coins"},
	]

	for child in milestone_container.get_children():
		child.queue_free()

	for data in milestone_data:
		var unlocked = RewardSystem.rewards_unlocked.get(data["name"], false)
		var label    = Label.new()

		if unlocked:
			label.text     = "⭐  " + data["label"] + "  ✅"
			label.modulate = Color(1, 0.85, 0)
		else:
			label.text     = "🔒  " + data["label"]
			label.modulate = Color(0.5, 0.5, 0.5)

		milestone_container.add_child(label)


# ============================================================
# LEVEL COINS SECTION
# ============================================================

func update_level_coins_section() -> void:
	if level_coins_label == null:
		return

	var text = "Coins per Level:\n"
	for level in RewardSystem.level_coins:
		var coins = RewardSystem.level_coins[level]
		text += "  " + level.capitalize() + ":  " + str(coins) + " coins\n"

	level_coins_label.text = text


# ============================================================
# SIGNALS
# ============================================================

func _on_reward_unlocked(_reward_name: String) -> void:
	refresh_display()


func _on_coins_changed(_new_total: int) -> void:
	update_coins_section()


# ============================================================
# BUTTONS
# ============================================================

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://princessgame/main menu.tscn")


func _on_reset_pressed() -> void:
	RewardSystem.reset_data()
	refresh_display()
	print("Reward data reset from gallery.")
