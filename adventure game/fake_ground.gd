extends StaticBody2D

@onready var detection_area = $DetectionArea

var is_standing = false
var timer_active = false

func _ready() -> void:
	if not detection_area.body_entered.is_connected(_on_body_entered):
		detection_area.body_entered.connect(_on_body_entered)
	if not detection_area.body_exited.is_connected(_on_body_exited):
		detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# 🛠️ 修复 1：使用更安全的模糊匹配或分组判定玩家
	if (body.is_in_group("player") or "player" in body.name.to_lower()) and not timer_active:
		is_standing = true
		timer_active = true
		
		# 等待 0.5 秒
		await get_tree().create_timer(0.5).timeout
		
		# 🛠️ 修复 2：时间到了之后，必须确保玩家“依然还在”这个地面上站着，才触发碎裂
		if is_standing and is_instance_valid(body):
			print("❄️ 地面碎裂！玩家开始下落。")
			# 确保你的玩家脚本（player.gd）里有 func start_fall() 这个函数
			if body.has_method("start_fall"):
				body.start_fall()
			
			queue_free() # 地面消失
		else:
			# 如果时间到了玩家已经离开了，就把定时器标记重置，允许下次踩踏
			timer_active = false

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or "player" in body.name.to_lower():
		is_standing = false
		# 注意：这里不要直接把 timer_active 设为 false，让上面的 await 逻辑自己去重置它，防止连续跳跃导致的计时器冲突
