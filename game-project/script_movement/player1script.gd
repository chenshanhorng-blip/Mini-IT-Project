extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = -550.0
@export var crouch_speed = 100.0
@export var air_crouch_boost = 1.5

# --- Health & Speed ---
@export var max_health: int = 100
var health: int = 100
var speed_modifier: float = 1.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var is_crouching = false
var original_height = 38.0
var crouch_height = 20.0
var is_falling = false
var start_position = Vector2.ZERO
var death_screen = null

var is_teleporting = false

func _ready():
	start_position = global_position
	health = max_health

	if collision_shape and collision_shape.shape:
		original_height = collision_shape.shape.get_rect().size.y
		crouch_height = original_height * 0.6

	var death_screen_path = "res://scene/UI/death_screen.tscn"
	if ResourceLoader.exists(death_screen_path):
		death_screen = load(death_screen_path).instantiate()
		add_child(death_screen)
		print("Death screen loaded successfully.")
	else:
		print("Death screen does not exist: ", death_screen_path)

	if CheckpointManager:
		CheckpointManager.player_respawn.connect(_on_player_respawn)
		print("Respawn signal connected.")

	add_to_group("player")
	print("Player added to 'player' group.")

func _physics_process(delta):
	if is_falling:
		velocity.x = 0
		velocity.y += 80
		move_and_slide()
		animated_sprite.play("fall")

		if position.y > 650:
			die()
		return

	if is_teleporting:
		move_and_slide()
		return

	var crouch_pressed = Input.is_action_pressed("p1_down")

	if crouch_pressed:
		if not is_crouching:
			start_crouch()
		if not is_on_floor() and velocity.y > 0:
			velocity.y += 80 * air_crouch_boost * delta
	else:
		if is_crouching and is_on_floor():
			stop_crouch()

	var direction = Input.get_axis("p1_left", "p1_right")
	var current_speed = crouch_speed if is_crouching else speed
	current_speed = current_speed * speed_modifier
	velocity.x = direction * current_speed

	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	if not is_on_floor():
		velocity.y += 50

	move_and_slide()
	update_animations(direction)

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
	is_teleporting = false
	global_position = checkpoint_position
	velocity = Vector2.ZERO

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

func apply_speed_modifier(modifier: float) -> void:
	speed_modifier = modifier
	if modifier < 1.0:
		print("Player entered vine trap: Slowed down to ", modifier * 100, "%")
	else:
		print("Player escaped vine trap: Speed restored.")

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage! Health remaining: ", health)

	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		die()

func teleport_to(target_pos: Vector2) -> void:
	is_teleporting = true
	velocity = Vector2.ZERO

	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 0), 0.15)

	await tween.finished
	global_position = target_pos

	tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.15)

	await tween.finished
	is_teleporting = false
	print("Player teleported to: ", target_pos)