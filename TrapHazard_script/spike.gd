extends Area2D

@export var damage_amount: int = 40
@export var knockback_force: float = 500.0

# Time in seconds for each state
@export var hidden_duration: float = 2.0  # How long it stays underground
@export var active_duration: float = 1.5  # How long it stays extended

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var state_timer: Timer = $Timer
<<<<<<< HEAD
@onready var spike_sound = $SpikeSound
=======
>>>>>>> bfa5809f37f3978beea1e15c6cfe180f2c411237

var is_active: bool = false

func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)
	state_timer.timeout.connect(_on_state_timer_timeout)
	
	# Start in the retracted (hidden) state
	retract_spikes()

func _on_body_entered(body: Node2D) -> void:
	# Only damage the player if the spikes are actually popped up
	if is_active and body.is_in_group("player"):
		body.take_damage(damage_amount)
		
		# Knockback logic
		var knockback_direction = (body.global_position - global_position).normalized()
		knockback_direction.y = -0.8 # Force the player upwards
		knockback_direction = knockback_direction.normalized()
		
		body.velocity = knockback_direction * knockback_force
		body.move_and_slide()
		print("Player hit by active spike trap!")

func _on_state_timer_timeout() -> void:
	# Toggle between active and retracted states when timer finishes
	if is_active:
		retract_spikes()
	else:
		pop_up_spikes()

func pop_up_spikes() -> void:
	is_active = true
	print("Spike Trap Activated!")
	
	# 1. Play animation
	animated_sprite.play("pop_up")
	
	# 2. Enable the hit area so player can take damage
	collision_shape.set_deferred("disabled", false)
	
	# 3. Wait for the active duration before shrinking back
	state_timer.start(active_duration)

func retract_spikes() -> void:
	is_active = false
	print("Spike Trap Disarmed (Hidden).")
	
	# 1. Play hidden animation
	animated_sprite.play("retracted")
	
	# 2. Disable the hit area so player can safely walk over it
	collision_shape.set_deferred("disabled", true)
	
	# 3. Wait for the hidden duration before popping up again
	state_timer.start(hidden_duration)
