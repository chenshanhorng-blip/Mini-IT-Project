extends Area2D

@onready var checkpoint_sound = $CheckpointSound
@export var checkpoint_id: int = 1
var activated = false
var can_activate = true  # prevents checkpoint from re-triggering right after respawn

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	if not can_activate:
		return
	if activated:
		return
	
	activated = true
	checkpoint_sound.play()
	
	# Save player's progress (scene, checkpoint ID, position) to a global manager
	CheckpointManager.save_checkpoint(
		get_tree().current_scene.name,
		checkpoint_id,
		global_position
	)
	
	print("🏁 到达检查点 ", checkpoint_id)

# Temporarily disable checkpoint when player respawns, 
# so it doesn't instantly re-trigger at the same spot
func disable_temp():
	can_activate = false
	await get_tree().create_timer(0.5).timeout
	can_activate = true

# Reset checkpoint state when starting a new game
func reset_activation():
	activated = false
