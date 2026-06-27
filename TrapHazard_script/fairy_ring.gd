# FairyRing.gd
extends Area2D

@export var teleport_destinations: Array[Node2D] = []
@export var cooldown_time: float = 1.5

# 保持你原有的安全获取节点声明
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var fairy_ring_sound = $FairyRingSound

var can_teleport = true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and can_teleport:
		if teleport_destinations.is_empty():
			print("Warning: No teleport destinations set for ", name)
			return

		var destination = teleport_destinations.pick_random()
		
		if is_instance_valid(destination):
			_teleport_player(body, destination.global_position)

			if destination.has_method("force_cooldown"):
				destination.force_cooldown()

# 合并了重复的函数，保留了你带 await 的最新逻辑
func _teleport_player(player, target_pos):
	can_teleport = false
	
	# 使用顶部声明好的 particles 变量，更安全
	if particles:
		particles.emitting = true
	
	fairy_ring_sound.play()
	
	# 保持你的玩家传送和冷却逻辑
	player.teleport_to(target_pos)
	
	await get_tree().create_timer(cooldown_time).timeout
	can_teleport = true

func force_cooldown():
	can_teleport = false
	await get_tree().create_timer(cooldown_time).timeout
	can_teleport = true
