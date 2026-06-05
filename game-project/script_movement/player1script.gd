extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = -550.0
@export var crouch_speed = 100.0
@export var air_crouch_boost = 1.5

# --- New Toxic Swamp Variables ---
@export var max_health: int = 100
var health: int = 100
var speed_modifier: float = 1.0  # 1.0 = normal, 0.5 = 50% slowed

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var is_crouching = false
var original_height = 38.0
var crouch_height = 20.0
var is_falling = false
var start_position = Vector2.ZERO
var death_screen = null

func _ready():
	start_position = global_position
	health = max_health
	
	if collision_shape and collision_shape.shape:
		original_height = collision_shape.shape.get_rect().size.y
		crouch_height = original_height * 0.6
	
	# Load Death Screen
	var death_screen_path = "res://scene/UI/death_screen.tscn"
	if ResourceLoader.exists(death_screen_path):
		death_screen = load(death_screen_path).instantiate()
		add_child(death_screen)
		print("Death screen loaded successfully.")
	else:
		print("Death screen does not exist: ", death_screen_path)
	
	# Connect Respawn Signal
	if CheckpointManager:
		CheckpointManager.player_respawn.connect(_on_player_respawn)
		print("Respawn signal connected.")
	
	# Add to Player Group
	add_to_group("player")
	print("Player added to 'player' group.")

func _physics_process(delta):
	# Falling state: falling down automatically, lose control
	if is_falling:
		velocity.x = 0
		velocity.y += 80
		move_and_slide()
		animated_sprite.play("fall")
		
		# Die when falling past screen bounds
		if position.y > 650:
			die()
		return
	
	# Crouch Input
	var crouch_pressed = Input.is_action_pressed("p1_down")
	
	if crouch_pressed:
		if not is_crouching:
			start_crouch()
		# Boost falling speed when crouching in mid-air
		if not is_on_floor() and velocity.y > 0:
			velocity.y += 80 * air_crouch_boost * delta
	else:
		# Stand up when releasing button on floor
		if is_crouching and is_on_floor():
			stop_crouch()
	
	# Movement & Speed Calculation
	var direction = Input.get_axis("p1_left", "p1_right")
	var current_speed = crouch_speed if is_crouching else speed
	
	# Apply the environmental speed modifier (e.g., Toxic Swamp slow)
	current_speed = current_speed * speed_modifier
	velocity.x = direction * current_speed
	
	# Jumping
	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity
	
	# Gravity
	if not is_on_floor():
		velocity.y += 50
	
	move_and_slide()
	update_animations(direction)
	
	# Fall trigger setup
	if position.y > 600 and not is_falling:
		start_fall()

func update_animations(direction):
	if is_crouching:
		animated_sprite.play("crouch")
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return
	
	if direction != 0:
		if direction > 0:
			animated_sprite.play("right_move")
		else:
			animated_sprite.play("left_move")
	else:
		animated_sprite.play("idle")

func start_crouch():
	if is_crouching:
		return
	is_crouching = true
	
	if is_on_floor() and collision_shape and collision_shape.shape:
		var new_shape = RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, crouch_height))
		collision_shape.shape = new_shape
		position.y += (original_height - crouch_height) / 2

func stop_crouch():
	if not is_crouching:
		return
	
	is_crouching = false
	
	if collision_shape and collision_shape.shape:
		var new_shape = RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, original_height))
		collision_shape.shape = new_shape
		position.y -= (original_height - crouch_height) / 2

func start_fall():
	if is_falling:
		return
	print("Player started falling.")
	is_falling = true

func die():
	print("Player died.")
	set_physics_process(false)
	if death_screen:
		death_screen.show_death_screen()
	else:
		get_tree().reload_current_scene()

func respawn_at_checkpoint(checkpoint_position: Vector2):
	print("Respawning at: ", checkpoint_position)
	is_falling = false
	is_crouching = false
	global_position = checkpoint_position
	velocity = Vector2.ZERO
	
	# Reset status attributes on respawn
	health = max_health
	speed_modifier = 1.0
	
	if collision_shape and collision_shape.shape:
		var normal_shape = RectangleShape2D.new()
		normal_shape.set_size(Vector2(original_height, original_height))
		collision_shape.shape = normal_shape
	
	set_physics_process(true)
	print("Respawn complete.")

func _on_player_respawn(checkpoint_position: Vector2):
	print("Received respawn signal.")
	respawn_at_checkpoint(checkpoint_position)

func respawn():
	respawn_at_checkpoint(start_position)

# --- New Damage & Slow Interfaces Called By Trap ---
func take_damage(amount: int) -> void:
	health -= amount
	print("Player took poison damage! Health remaining: ", health)
	
	# Visual Hit Flash (Quickly flashes red then resets)
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)
	
	if health <= 0:
		die()

func apply_speed_modifier(modifier: float) -> void:
	speed_modifier = modifier
	if modifier < 1.0:
		print("Player entered the swamp: Slowed down.")
	else:
		print("Player left the swamp: Speed restored.")
@export var speed = 300.0

@onready var sprite = $Sprite2D

func _physics_process(delta):
	var direction = Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	velocity = direction * speed
	
	if direction.x !=0:
		sprite.flip_h = direction.x<0
	
	move_and_slide()
