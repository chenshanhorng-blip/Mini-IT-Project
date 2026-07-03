extends RigidBody2D

@export var fall_delay = 0.5
@export var impact_damage = 30

var triggered = false
var damage_dealt = false  # Prevent multiple damage

func _ready():
	freeze = true
	gravity_scale = 10
	contact_monitor = true
	max_contacts_reported = 4

	# Detect collision with the player
	if not body_entered.connect(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_detection_area_body_entered(body):
	# Trigger the falling rock when the player enters the detection area
	if body.is_in_group("player") and not triggered:
		triggered = true
		rumble()

		await get_tree().create_timer(fall_delay).timeout

		freeze = false
		linear_velocity = Vector2(0, 600)

func rumble():
	# Shake the rock before it falls
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(3, 0), 0.05)
	tween.tween_property(self, "position", position + Vector2(-3, 0), 0.05)
	tween.tween_property(self, "position", position + Vector2(3, 0), 0.05)
	tween.tween_property(self, "position", position, 0.05)

func _on_body_entered(body):
	# Deal damage when the falling rock hits the player
	if body.is_in_group("player") and not damage_dealt:
		damage_dealt = true
		body.take_damage(impact_damage)
		print("Damage dealt: ", impact_damage)

		# Keep the rock falling after the collision
		await get_tree().process_frame
		linear_velocity = Vector2(0, 600)
