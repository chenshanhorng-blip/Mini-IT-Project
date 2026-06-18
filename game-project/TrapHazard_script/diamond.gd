extends Area2D

signal collected

func _ready() -> void:
	# 安全连接信号
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered diamond: ", body.name)
	
	# 🛠️ 修复：只要碰撞物体的名字包含 "player"（不分大小写），或者属于 "player" 分组，就判定为收集成功
	if body.is_in_group("player") or "player" in body.name.to_lower():
		print("💎 ", body.name, " 成功收集了钻石！")
		collected.emit()   # 触发关卡脚本里的 _on_point_collected
		queue_free()       # 钻石消失
