# FairyRing.gd
extends Area2D

@export var teleport_destinations: Array[Node2D] = []
@export var cooldown_time: float = 1.5

var can_teleport = true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and can_teleport:
		if teleport_destinations.is_empty():
			return
		var destination = teleport_destinations.pick_random()
		_teleport_player(body, destination.global_position)
		
		# ✅ 目的地的圈也一起冷却
		if destination.has_method("force_cooldown"):
			destination.force_cooldown()

func _teleport_player(player, target_pos):
	can_teleport = false
	
	# $AudioStreamPlayer2D.play()  ← 已删除
	$GPUParticles2D.emitting = true
	
	player.teleport_to(target_pos)
	
	await get_tree().create_timer(cooldown_time).timeout
	can_teleport = true

# ✅ 新增：被外部强制冷却
func force_cooldown():
	can_teleport = false
	await get_tree().create_timer(cooldown_time).timeout
	can_teleport = true
