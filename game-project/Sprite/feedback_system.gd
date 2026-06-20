extends Panel
# 🌟 核心：当玩家点击任何按钮关闭面板时发出的自定义信号
signal feedback_closed

const SAVE_PATH = "user://feedback_settings.cfg"
var dont_ask_again = false

func _ready():
	load_settings()
	
	# 🛠️ 已经帮你修改：改回 hide() 隐藏状态！
	# 这样游戏刚开局它会自动隐身，只有通关时才会被你用代码调用出来
	hide()

# ==========================================
# 🌟 新增：统一入口，关卡脚本通关时只需要调用这个函数
# 不用自己再判断 dont_ask_again，逻辑全部交给这里处理
# 用法：feedback_panel.try_show()
# ==========================================
func try_show():
	if dont_ask_again:
		# 玩家之前选了"不再提示"，直接跳过面板，
		# 但仍然要发出 feedback_closed，让关卡脚本能切回地图
		print("[FeedbackPanel] dont_ask_again = true，跳过显示")
		feedback_closed.emit()
	else:
		print("[FeedbackPanel] 显示反馈面板")
		show()

# ==========================================
# Give Feedback (点击填写反馈)
# ==========================================
func _on_feedback_button_pressed():
	OS.shell_open("https://forms.gle/VRR3eEJCWbtgoafJ7")
	hide()
	feedback_closed.emit()

# ==========================================
# Later (稍后提示)
# ==========================================
func _on_later_button_pressed():
	hide()
	feedback_closed.emit()

# ==========================================
# Don't Ask Again (以后不再提示)
# ==========================================
func _on_dont_ask_again_button_pressed():
	dont_ask_again = true
	save_settings()
	hide()
	feedback_closed.emit()

# ==========================================
# 保存设置 
# ==========================================
func save_settings():
	var config = ConfigFile.new()
	config.set_value("feedback", "dont_ask_again", dont_ask_again)
	config.save(SAVE_PATH)

# ==========================================
# 读取设置 
# ==========================================
func load_settings():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		dont_ask_again = config.get_value("feedback", "dont_ask_again", false)
	print("[FeedbackPanel] 读取到 dont_ask_again = ", dont_ask_again)
