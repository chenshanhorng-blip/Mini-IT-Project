# FairyRing.gd
extends Area2D

@export var teleport_destinations: Array[Node2D] = []
@export var cooldown_time: float = 1.5

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var fairy_ring_sound = $FairyRingSound

# Track cooldown per player body so multiple players don't block each other
# and so the destination ring doesn't immediately re-teleport the arriving player
var players_on_cooldown: Array = []


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	# Skip if this specific player is still on cooldown
	if body in players_on_cooldown:
		return

	if teleport_destinations.is_empty():
		print("Warning: No teleport destinations set for ", name)
		return

	var destination = teleport_destinations.pick_random()
	if is_instance_valid(destination):
		_teleport_player(body, destination.global_position)

		if destination.has_method("force_cooldown_for_player"):
			destination.force_cooldown_for_player(body)


func _teleport_player(player, target_pos):
	# Add player to cooldown list so this ring won't re-teleport them immediately
	players_on_cooldown.append(player)

	if particles:
		particles.emitting = true

	fairy_ring_sound.play()

	player.teleport_to(target_pos)

	await get_tree().create_timer(cooldown_time).timeout

	# Remove player from cooldown so they can use rings again
	players_on_cooldown.erase(player)


# Called on the DESTINATION ring so the arriving player isn't
# immediately teleported back by the destination ring
func force_cooldown_for_player(player) -> void:
	if player not in players_on_cooldown:
		players_on_cooldown.append(player)
	await get_tree().create_timer(cooldown_time).timeout
	players_on_cooldown.erase(player)


# Keep old force_cooldown for compatibility
func force_cooldown():
	await get_tree().create_timer(cooldown_time).timeout
