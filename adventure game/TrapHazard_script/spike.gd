extends Area2D

@export var damage_amount: int = 40
@export var knockback_force: float = 500.0

# Duration for each spike trap state
@export var hidden_duration: float = 2.0
@export var active_duration: float = 1.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var state_timer: Timer = $Timer
@onready var spike_sound = $SpikeSound

var is_active: bool = false

func _ready() -> void:
	# Connect signals and start in the hidden state
	body_entered.connect(_on_body_entered)
	state_timer.timeout.connect(_on_state_timer_timeout)

	retract_spikes()

func _on_body_entered(body: Node2D) -> void:
	# Damage the player only when the spikes are active
	if is_active and body.is_in_group("player"):
		body.take_damage(damage_amount)

		# Apply knockback to the player
		var knockback_direction = (body.global_position - global_position).normalized()
		knockback_direction.y = -0.8
		knockback_direction = knockback_direction.normalized()

		body.velocity = knockback_direction * knockback_force
		body.move_and_slide()
		print("Player hit by active spike trap!")

func _on_state_timer_timeout() -> void:
	# Switch between hidden and active states
	if is_active:
		retract_spikes()
	else:
		pop_up_spikes()

func pop_up_spikes() -> void:
	is_active = true
	print("Spike Trap Activated!")

	animated_sprite.play("pop_up")

	# Enable collision so the trap can deal damage
	collision_shape.set_deferred("disabled", false)

	state_timer.start(active_duration)

func retract_spikes() -> void:
	is_active = false
	print("Spike Trap Disarmed (Hidden).")

	animated_sprite.play("retracted")

	# Disable collision while the trap is hidden
	collision_shape.set_deferred("disabled", true)

	state_timer.start(hidden_duration)
