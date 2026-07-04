extends CanvasLayer

# REWARD POPUP — expanded
#stores a function to run when Continue is pressed, set from outside
var on_continue_pressed: Callable
#remembers which level we're currently showing
var level_name_current: String = ""
# grab all the panel and standby when the panel need to use
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
	hide()#hide the popup at the start when the player is not complete the level
	process_mode = PROCESS_MODE_ALWAYS# lets this popup keep working even if the game is paused


	if continue_btn:#clicking Continue runs its function
		continue_btn.pressed.connect(_on_continue_pressed)
	if replay_btn:#clicking Replay runs its function
		replay_btn.pressed.connect(_on_replay_pressed)

	# Connect to reward unlocked signal
	if not RewardSystem.reward_unlocked.is_connected(_on_reward_just_unlocked):
		RewardSystem.reward_unlocked.connect(_on_reward_just_unlocked)



# SHOW REWARD — call from level script
# diamonds_collected = how many diamonds player got (0-3)
#the functionn to show the reward the system
func show_reward(level_name: String, base_coins: int, bonus_coins: int = 0, diamonds_collected: int = 3) -> void:
	level_name_current = level_name#the current level 

	var medal      = get_medal_name(level_name)#the medal in each level 
	var stars      = get_stars(diamonds_collected)#the star is follow the diamond collected
	var total_lvl  = base_coins + bonus_coins#the total of the coins show to the 

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

	show()# show the popup
	get_tree().paused  #pause the game so nothing moves in the background
	print("Reward popup shown for:", level_name)

	# make the title do a little pulse animation
	_animate_title()

# STARS — based on diamonds collected

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


# ANIMATE TITLE — simple scale pulse
#  makes the title text grow and shrink a few times
func _animate_title() -> void:
	if title_label == null:#skip if the title label doesn't exist
		return
	#create a tween tool that smoothly animates values over time
	var tween = create_tween()
	#this is for the animation become big and small 
	tween.tween_property(title_label, "scale", Vector2(1.1, 1.1), 0.3)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.3)
	tween.set_loops(3)# it will repeat 3 times of tween 
	
# REWARD UNLOCKED SIGNAL — show it in popup
#runs if a new reward unlocks while this popup is open
func _on_reward_just_unlocked(reward_name: String) -> void:
	if new_reward_label == null:#skip if the label doesn't exist
		return
	# turn the internal name (like "gold_medal") into readable text ("Gold Medal")
	var display = reward_name.replace("_", " ").capitalize()
	new_reward_label.text  = "🎉 New Reward: " + display + " Unlocked!"
	new_reward_label.visible = true#make the line become visible

	# Update grand total
	if grand_total_label:
		grand_total_label.text = "💰 Total Coins:  " + str(RewardSystem.total_coins)

# BUTTONS

func _on_continue_pressed() -> void:
	hide()# hide the popup
	get_tree().paused = false#unpause, let the game resume
	if on_continue_pressed.is_valid():
		on_continue_pressed.call()
	else:#go to the scene of map.tscn
		Transition.fade_to_scene("res://scene_level_map/map.tscn")


func _on_replay_pressed() -> void:
	hide()# hide the popup
	get_tree().paused = false#unpause, let the game resume
	get_tree().reload_current_scene()#reload the current scene
