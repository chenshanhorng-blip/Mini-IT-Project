extends Panel

const SAVE_PATH = "user://feedback_settings.cfg"

var dont_ask_again = false


func _ready():

	load_settings()

	# 如果玩家按过 Don't Ask Again
	#if dont_ask_again:
	#	hide()
		#return

	# 先显示 UI（测试用）
	show()


# =========================
# Give Feedback
# =========================
func _on_feedback_button_pressed():

	OS.shell_open("https://forms.gle/VRR3eEJCWbtgoafJ7")

	hide()


# =========================
# Later
# =========================
func _on_later_button_pressed():

	hide()


# =========================
# Don't Ask Again
# =========================
func _on_dont_ask_again_button_pressed():

	dont_ask_again = true

	save_settings()

	hide()


# =========================
# 保存设置
# =========================
func save_settings():

	var config = ConfigFile.new()

	config.set_value(
		"feedback",
		"dont_ask_again",
		dont_ask_again
	)

	config.save(SAVE_PATH)


# =========================
# 读取设置
# =========================
func load_settings():

	var config = ConfigFile.new()

	if config.load(SAVE_PATH) == OK:

		dont_ask_again = config.get_value(
			"feedback",
			"dont_ask_again",
			false
		)
