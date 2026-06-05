extends Area2D
 
@export var slow_amount: float = 0.3
@export var trap_duration: float = 2.0
 
var player_caught = false
 
func _ready():
	body_entered.connect(_on_body_entered)
	$Timer.wait_time = trap_duration
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timer_timeout)
 
func _on_body_entered(body):
	if body.is_in_group("player") and not player_caught:
		player_caught = true
		body.apply_speed_modifier(slow_amount)  # ✅ 调用函数，不是直接赋值
		$AnimatedSprite2D.play("grab")
		$Timer.start()
 
func _on_timer_timeout():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.apply_speed_modifier(1.0)      # ✅ 恢复速度
	player_caught = false
	$AnimatedSprite2D.play("idle")
