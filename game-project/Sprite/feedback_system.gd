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
# Give Feedback (点击填写反馈)
# ==========================================
func _on_feedback_button_pressed():
	# 调用系统浏览器打开谷歌问卷链接
	OS.shell_open("https://forms.gle/VRR3eEJCWbtgoafJ7")
	
	# 面板自己隐藏
	hide()
	
	# 发出关闭通知，告诉关卡脚本可以切回大地图了
	feedback_closed.emit()

# ==========================================
# Later (稍后提示)
# ==========================================
func _on_later_button_pressed():
	# 隐藏面板
	hide()
	
	# 发出关闭通知
	feedback_closed.emit()

# ==========================================
# Don't Ask Again (以后不再提示)
# ==========================================
func _on_dont_ask_again_button_pressed():
	# 标记为不再提示
	dont_ask_again = true
	
	# 保存配置到本地
	save_settings()
	
	# 隐藏面板
	hide()
	
	# 发出关闭通知
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
