extends Area2D

func _ready():
	# Detect when the player reaches the bottom of the pit
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("坑底碰到了：", body.name)  # 看有没有打印

	# Check if the collided object is the player
	if body.name == "CharacterBody2D":
		print("尝试复活")

		# Respawn the player if they are in the falling state
		if body.is_falling:
			print("掉落状态为 true，开始复活")
			body.respawn()
		else:
			print("掉落状态为 false")
