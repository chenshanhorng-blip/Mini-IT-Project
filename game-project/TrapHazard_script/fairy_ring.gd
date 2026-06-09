# FairyRing.gd
extends Area2D

@export var teleport_destinations: Array[Node2D] = []
@export var cooldown_time: float = 1.5

# Safely gets the particles node when the scene loads
@onready var particles: GPUParticles2D = $GPUParticles2D

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

func _teleport_player(player, target_pos):
	can_teleport = false

	# Play the particle effect if the node exists
	if particles:
		particles.emitting = true

	# Teleport the player
	player.global_position = target_pos

	# Wait for cooldown
	await get_tree().create_timer(cooldown_time).timeout
	can_teleport = true

func force_cooldown():
	can_teleport = false
	await get_tree().create_timer(cooldown_time).timeout
	can_teleport = true
