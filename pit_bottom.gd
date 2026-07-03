extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("坑底碰到了：", body.name)  # 看有没有打印
	if body.name == "CharacterBody2D":
		print("尝试复活")
		if body.is_falling:
			print("掉落状态为 true，开始复活")
			body.respawn()
		else:
			print("掉落状态为 false")
