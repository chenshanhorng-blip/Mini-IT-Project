# FairyRing.gd
extends Area2D

@export var teleport_destinations: Array[Node2D] = []
@export var cooldown_time: float = 1.5

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var fairy_ring_sound = $FairyRingSound

# Stores players currently on teleport cooldown
var players_on_cooldown: Array = []


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	# Only players can activate the fairy ring
	if not body.is_in_group("player")or body.is_in_group("Player"):
		return

	# Prevent repeated teleportation during cooldown
	if body in players_on_cooldown:
		return

	if teleport_destinations.is_empty():
		print("Warning: No teleport destinations set for ", name)
		return

	var destination = teleport_destinations.pick_random()
	if is_instance_valid(destination):
		_teleport_player(body, destination.global_position)

		# Apply cooldown to the destination ring as well
		if destination.has_method("force_cooldown_for_player"):
			destination.force_cooldown_for_player(body)


func _teleport_player(player, target_pos):
	# Start teleport cooldown for this player
	players_on_cooldown.append(player)

	if particles:
		particles.emitting = true

	fairy_ring_sound.play()

	player.teleport_to(target_pos)

	await get_tree().create_timer(cooldown_time).timeout

	players_on_cooldown.erase(player)


# Prevent the destination ring from teleporting the player back instantly
func force_cooldown_for_player(player) -> void:
	if player not in players_on_cooldown:
		players_on_cooldown.append(player)
	await get_tree().create_timer(cooldown_time).timeout
	players_on_cooldown.erase(player)


# Compatibility function for older scripts
func force_cooldown():
	await get_tree().create_timer(cooldown_time).timeout
