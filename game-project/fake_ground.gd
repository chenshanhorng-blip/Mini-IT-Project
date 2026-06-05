extends StaticBody2D

@onready var detection_area = $DetectionArea

var is_standing = false
var timer_active = false

func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "CharacterBody2D" and not timer_active:
		is_standing = true
		timer_active = true
		await get_tree().create_timer(0.5).timeout
		if is_standing:
			# 让玩家开始掉落
			body.start_fall()
			queue_free()  # 地面消失

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		is_standing = false
		timer_active = false
