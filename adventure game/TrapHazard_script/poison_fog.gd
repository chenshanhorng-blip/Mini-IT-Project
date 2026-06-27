extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 检查是否是玩家
	if body.is_in_group("player"):
		# 让玩家死亡（会触发死亡画面）
		if body.has_method("die"):
			body.die()
