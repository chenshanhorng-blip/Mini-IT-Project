extends CanvasLayer

# ============================================================
# REWARD POPUP — expanded
# Shows after level complete with:
# - Animated title
# - Coins earned + bonus coins breakdown
# - Medal earned with emoji
# - Total coins counter
# - Stars rating (1-3 based on performance)
# - Continue button → map
# - Replay button → restart level
# ============================================================

var on_continue_pressed: Callable
var level_name_current: String = ""

@onready var panel           = $Panel
@onready var title_label     = $Panel/VBoxContainer/TitleLabel
@onready var stars_label     = $Panel/VBoxContainer/StarsLabel
@onready var divider1        = $Panel/VBoxContainer/Divider1
@onready var coins_label     = $Panel/VBoxContainer/CoinsLabel
@onready var bonus_label     = $Panel/VBoxContainer/BonusLabel
@onready var total_level_label = $Panel/VBoxContainer/TotalLevelLabel
@onready var divider2        = $Panel/VBoxContainer/Divider2
@onready var medal_label     = $Panel/VBoxContainer/MedalLabel
@onready var new_reward_label = $Panel/VBoxContainer/NewRewardLabel
@onready var divider3        = $Panel/VBoxContainer/Divider3
@onready var grand_total_label = $Panel/VBoxContainer/GrandTotalLabel
@onready var btn_container   = $Panel/VBoxContainer/ButtonContainer
@onready var continue_btn    = $Panel/VBoxContainer/ButtonContainer/ContinueButton
@onready var replay_btn      = $Panel/VBoxContainer/ButtonContainer/ReplayButton


func _ready() -> void:
	hide()
	process_mode = PROCESS_MODE_ALWAYS

	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)
	if replay_btn:
		replay_btn.pressed.connect(_on_replay_pressed)

	# Connect to reward unlocked signal
	if not RewardSystem.reward_unlocked.is_connected(_on_reward_just_unlocked):
		RewardSystem.reward_unlocked.connect(_on_reward_just_unlocked)


# ============================================================
# SHOW REWARD — call from level script
# diamonds_collected = how many diamonds player got (0-3)
# ============================================================

func show_reward(level_name: String, base_coins: int, bonus_coins: int = 0, diamonds_collected: int = 3) -> void:
	level_name_current = level_name

	var medal      = get_medal_name(level_name)
	var stars      = get_stars(diamonds_collected)
	var total_lvl  = base_coins + bonus_coins

	# --- Title ---
	if title_label:
		title_label.text = "✨ Level Complete! ✨"

	# --- Stars rating ---
	if stars_label:
		stars_label.text = stars

	# --- Coins breakdown ---
	if coins_label:
		coins_label.text  = "Level Reward    +" + str(base_coins) + " coins"
	if bonus_label:
		bonus_label.text  = "Diamond Bonus  +" + str(bonus_coins) + " coins"
		bonus_label.visible = bonus_coins > 0
	if total_level_label:
		total_level_label.text = "This Level Total   " + str(total_lvl) + " coins"

	# --- Medal ---
	if medal_label:
		medal_label.text = "Medal Earned:  " + medal

	# --- New reward hint (updated by signal) ---
	if new_reward_label:
		new_reward_label.text = ""
		new_reward_label.visible = false

	# --- Grand total ---
	if grand_total_label:
		grand_total_label.text = "💰 Total Coins:  " + str(RewardSystem.total_coins)

	show()
	get_tree().paused = true
	print("Reward popup shown for:", level_name)

	# Animate title
	_animate_title()


# ============================================================
# STARS — based on diamonds collected
# ============================================================

func get_stars(diamonds: int) -> String:
	match diamonds:
		0: return "☆ ☆ ☆"
		1: return "★ ☆ ☆"
		2: return "★ ★ ☆"
		3: return "★ ★ ★"
	return "★ ★ ★"


# ============================================================
# MEDAL NAME
# ============================================================

func get_medal_name(level_name: String) -> String:
	match level_name:
		"level1": return "🥉 Bronze Medal"
		"level2": return "🥈 Silver Medal"
		"level3": return "🥇 Gold Medal"
		"level4": return "💎 Diamond Medal"
		"level5": return "🏆 Champion"
	return "⭐ Medal"


# ============================================================
# ANIMATE TITLE — simple scale pulse
# ============================================================

func _animate_title() -> void:
	if title_label == null:
		return
	var tween = create_tween()
	tween.tween_property(title_label, "scale", Vector2(1.1, 1.1), 0.3)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.3)
	tween.set_loops(3)


# ============================================================
# REWARD UNLOCKED SIGNAL — show it in popup
# ============================================================

func _on_reward_just_unlocked(reward_name: String) -> void:
	if new_reward_label == null:
		return
	var display = reward_name.replace("_", " ").capitalize()
	new_reward_label.text  = "🎉 New Reward: " + display + " Unlocked!"
	new_reward_label.visible = true

	# Update grand total
	if grand_total_label:
		grand_total_label.text = "💰 Total Coins:  " + str(RewardSystem.total_coins)


# ============================================================
# BUTTONS
# ============================================================

func _on_continue_pressed() -> void:
	hide()
	get_tree().paused = false
	if on_continue_pressed.is_valid():
		on_continue_pressed.call()
	else:
		get_tree().change_scene_to_file("res://scene_level_map/map.tscn")


func _on_replay_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()
