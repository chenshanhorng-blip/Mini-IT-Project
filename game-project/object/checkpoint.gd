extends Area2D

@export var checkpoint_id: int = 1
var activated = false
var can_activate = true  # 新增：是否可以被激活

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	# 检查是否可以被激活
	if not can_activate:
		return
	
	if activated:
		return
	
	activated = true
	
	CheckpointManager.save_checkpoint(
		get_tree().current_scene.name,
		checkpoint_id,
		body.global_position
	)
	
	print("🏁 到达检查点 ", checkpoint_id)

# 临时禁用检查点（复活时调用）
func disable_temp():
	can_activate = false
	# 0.5 秒后重新启用
	await get_tree().create_timer(0.5).timeout
	can_activate = true

# 重置激活状态（用于新的游戏）
func reset_activation():
	activated = false
