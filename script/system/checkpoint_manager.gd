extends Node

var current_level: String = ""
var current_checkpoint_id: int = 0
var last_checkpoint_position: Vector2 = Vector2.ZERO

signal checkpoint_reached(level_name: String, checkpoint_id: int)
signal player_respawn(position: Vector2)

func save_checkpoint(level_name: String, checkpoint_id: int, position: Vector2):
	current_level = level_name
	current_checkpoint_id = checkpoint_id
	last_checkpoint_position = position
	print("✅ 检查点已保存: ", level_name, " ID:", checkpoint_id, " 位置:", position)
	checkpoint_reached.emit(level_name, checkpoint_id)

func get_last_checkpoint_position() -> Vector2:
	return last_checkpoint_position

func get_last_checkpoint_id() -> int:
	return current_checkpoint_id

func respawn_player():
	print("respawn_player 被调用")
	print("当前检查点位置: ", last_checkpoint_position)
	
	if last_checkpoint_position != Vector2.ZERO:
		print("发射 player_respawn 信号")
		player_respawn.emit(last_checkpoint_position)
		return true
	else:
		print("没有检查点，重新开始关卡")
		get_tree().reload_current_scene()
		return false

func reset_checkpoint(level_name: String, start_position: Vector2):
	current_level = level_name
	current_checkpoint_id = 0
	last_checkpoint_position = start_position
	print("检查点已重置: ", level_name, " 起点:", start_position)
