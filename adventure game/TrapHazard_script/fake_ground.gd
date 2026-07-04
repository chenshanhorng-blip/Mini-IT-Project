extends StaticBody2D

@onready var detection_area = $DetectionArea

var is_standing = false
var timer_active = false

func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	print("假地面已加载")

func _on_body_entered(body):
	print("进入地面检测，物体: ", body.name)
	
	# Trigger only when the player steps on the fake platform
	if body.is_in_group("player") and not timer_active:
		print("玩家站在假地面上，0.5秒后掉落")
		is_standing = true
		timer_active = true

		# Wait before the platform collapses
		await get_tree().create_timer(0.5).timeout

		if is_standing:
			print("玩家还在上面，开始掉落")

			# Make the player fall and remove the platform
			if body.has_method("start_fall"):
				body.start_fall()
				print("已调用 start_fall()")
			else:
				print("错误：玩家没有 start_fall() 方法")

			queue_free()

func _on_body_exited(body):
	# Cancel the collapse if the player leaves early
	if body.is_in_group("player"):
		print("玩家离开假地面")
		is_standing = false
		timer_active = false
