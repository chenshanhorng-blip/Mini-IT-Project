extends Area2D

func _ready() -> void:
	# 安全连接碰撞信号
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered trap: ", body.name) 
	
	# 检测碰到的物体是不是玩家
	if body.is_in_group("player") or "player" in body.name.to_lower():
		print("💥 玩家踩到陷阱！触发玩家自带的死亡与死亡屏幕...")
		
		# 🌟 直接调用你玩家脚本第 286 行的 die() 函数
		if body.has_method("die"):
			body.die() 
		else:
			# 保底防卡死机制：万一找不到玩家脚本的方法，直接用系统强制切换/重启
			print("⚠️ 警告：玩家身上没有找到 die() 方法，执行保底重启。")
			get_tree().reload_current_scene()
