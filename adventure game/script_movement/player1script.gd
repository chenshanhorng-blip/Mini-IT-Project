# res://script_movement/player1script.gd
extends CharacterBody2D

# ============================================================
# LEVEL MOVEMENT + SKILL SYSTEM COMBINED PLAYER 1 SCRIPT
# ============================================================

@export var speed: float = 200.0
@export var jump_velocity: float = -550.0
@export var crouch_speed: float = 100.0
@export var air_crouch_boost: float = 1.5

# Level / map status
@export var max_health: int = 100
var health: int = 100
var speed_modifier: float = 1.0

var is_crouching: bool = false
var is_falling: bool = false
var is_dead: bool = false

var original_height: float = 38.0
var crouch_height: float = 20.0
var start_position: Vector2 = Vector2.ZERO
var crouch_sprite_offset: float = 0.0
var death_screen = null

var is_teleporting = false
# Skill / character status
var stat: CharacterStat = null
var facing_direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var jump_sound = $JumpSound

# These nodes must be copied from princessgame/player1_movement.tscn
@onready var skill_controller = get_node_or_null("skill_adjust")
@onready var player_hud = get_node_or_null("CanvasLayer/Player")

const KNIGHT_SCALE   = Vector2(0.07469446, 0.079385417)
const PRINCESS_SCALE = Vector2(0.063069446, 0.063385417)


func _ready() -> void:
	start_position = global_position
	health = max_health
	add_to_group("player")

	if collision_shape and collision_shape.shape:
		original_height = collision_shape.shape.get_rect().size.y
		crouch_height = original_height * 0.6

	setup_character_stat()
	setup_skill_system()
	setup_death_screen()
	setup_checkpoint_signal()

	print("Player1 level + skill script ready.")


# ============================================================
# SETUP CHARACTER + SKILL
# ============================================================

func setup_character_stat() -> void:
	if Global.player1_character != null:
		stat = Global.player1_character
	else:
		stat = Create_Character.Create_Character(Create_Character.CharacterType.BOAR_PRINCESS)
		Global.player1_character = stat

	if stat == null:
		print("ERROR: stat is null. Character was not created.")
		return

	SkillSystem.apply_passive_on_start(stat)
	speed = stat.current_movement

	if not stat.health_depleted.is_connected(on_player_dead):
		stat.health_depleted.connect(on_player_dead)

	setup_character_sprite()

	print("Using character: ", stat.character_name)
	stat.print_stat()


func setup_skill_system() -> void:
	if skill_controller == null:
		print("ERROR: skill_adjust node missing.")
		return

	if stat == null:
		print("ERROR: stat is null, skill system cannot setup.")
		return

	skill_controller.setup(self, stat)

	if player_hud != null:
		player_hud.setup(stat)
	else:
		print("WARNING: CanvasLayer/Player HUD missing. Skill still works, but HP UI may not update.")


func setup_character_sprite() -> void:
	if stat == null:
		return

	if stat.character_name == "Boar Princess":
		animated_sprite.scale = PRINCESS_SCALE
		play_if_exists("idle")
		
	elif stat.character_name == "Tea Egg Knight":
		animated_sprite.scale = KNIGHT_SCALE
		play_if_exists("idle_2")
		

func setup_death_screen() -> void:
	var death_screen_path = "res://scene/UI/death_screen.tscn"

	if ResourceLoader.exists(death_screen_path):
		death_screen = load(death_screen_path).instantiate()
		add_child(death_screen)
		print("Death screen loaded successfully.")
	else:
		print("Death screen does not exist: ", death_screen_path)


func setup_checkpoint_signal() -> void:
	if CheckpointManager:
		if not CheckpointManager.player_respawn.is_connected(_on_player_respawn):
			CheckpointManager.player_respawn.connect(_on_player_respawn)
		print("Respawn signal connected.")

	add_to_group("player")
	print("Player added to 'player' group.")


# ============================================================
# INPUT / SKILL
# ============================================================

func _process(_delta: float) -> void:
	if is_dead:
		return

	if stat == null or skill_controller == null:
		return

	skill_controller.handle_input()


# ============================================================
# LEVEL MOVEMENT
# ============================================================

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_falling:
		velocity.x = 0
		velocity.y += 80
		move_and_slide()
		play_level_animation("fall")

		if position.y > 650:
			die()
		return

	if is_teleporting:
		move_and_slide()
		return

	var crouch_pressed := Input.is_action_pressed("p1_down")

	if crouch_pressed:
		if not is_crouching:
			start_crouch()

		if not is_on_floor() and velocity.y > 0:
			velocity.y += 80 * air_crouch_boost * delta
	else:
		if is_crouching and is_on_floor():
			stop_crouch()

	var direction := Input.get_axis("p1_left", "p1_right")
	var current_speed := crouch_speed if is_crouching else speed
	current_speed *= speed_modifier

	velocity.x = direction * current_speed

	if direction != 0:
		facing_direction = Vector2(direction, 0)
		animated_sprite.flip_h = direction < 0

	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	if not is_on_floor():
		velocity.y += 50

	move_and_slide()
	update_animations(direction)

	# Universal fall death — catches falls off platform edges even
	# when no pit trigger zone exists to set is_falling = true
	if position.y > 650 and not is_dead:
		die()

	# Prevent getting stuck inside enemies
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("enemy"):
			var push_dir = (global_position - collider.global_position).normalized()
			global_position += push_dir * 2



func update_animations(direction: float) -> void:
	if skill_controller != null and skill_controller.is_attacking:
		return

	var is_knight := stat != null and stat.character_name == "Tea Egg Knight"

	if is_crouching:
		play_move_animation("down_2" )
		if not is_knight :
			play_move_animation("down")
		return

	if not is_on_floor():
		if velocity.y < 0:
			jump_sound.play()
			play_move_animation("jump" if not is_knight else "jump_left_2")
		else:
			play_move_animation("fall" if not is_knight else "fall_2")
		return

	if direction > 0:
		play_move_animation("right_move" if not is_knight else "right_move_2")
	elif direction < 0:
		play_move_animation("left_move" if not is_knight else "left_move_2")
	else:
		play_move_animation("idle" if not is_knight else "idle_2")


func play_move_animation(anim_name: String) -> void:
	if animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)


func play_level_animation(anim_name: String) -> void:
	if animated_sprite.sprite_frames == null:
		return

	if animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)
	else:
		if stat != null:
			if stat.character_name == "Boar Princess":
				play_if_exists("idle")
			elif stat.character_name == "Tea Egg Knight":
				play_if_exists("idle_2")


func play_if_exists(anim_name: String) -> void:
	if animated_sprite.sprite_frames == null:
		return

	if animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)
	else:
		print("Missing animation: ", anim_name)


# ============================================================
# CROUCH
# ============================================================

func start_crouch() -> void:
	if is_crouching:
		return

	is_crouching = true

	if is_on_floor() and collision_shape and collision_shape.shape:
		var new_shape := RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, crouch_height))
		collision_shape.shape = new_shape
		# Move only the collision shape down — NOT the whole node or sprite
		collision_shape.position.y += (original_height - crouch_height) / 2


func stop_crouch() -> void:
	if not is_crouching:
		return

	is_crouching = false

	if collision_shape and collision_shape.shape:
		var new_shape := RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, original_height))
		collision_shape.shape = new_shape
		collision_shape.position.y -= (original_height - crouch_height) / 2


# ============================================================
# DEATH / RESPAWN / CHECKPOINT
# ============================================================

func start_fall() -> void:
	if is_falling:
		return

	print("Player started falling.")
	is_falling = true


func die() -> void:
	if is_dead:
		return

	print("Player died.")

	if Global.game_mode == "multiplayer":
		# Multiplayer — quiet auto-respawn, don't interrupt other player
		is_dead = true
		is_falling = false
		velocity = Vector2.ZERO
		animated_sprite.visible = false
		set_physics_process(false)

		await get_tree().create_timer(2.0).timeout

		var respawn_pos = CheckpointManager.get_last_checkpoint_position()
		respawn_at_checkpoint(respawn_pos if respawn_pos != Vector2.ZERO else start_position)
		return

	# Single player — on_player_dead handles everything including death screen
	on_player_dead()


func on_player_dead() -> void:
	if is_dead:
		return
 
	# During tutorial — just respawn, no death screen
	if TutorialManager.tutorial_active:
		is_dead = true
		is_falling = false
		velocity = Vector2.ZERO
		set_physics_process(false)

		global_position = start_position

		if stat != null:
			stat.reset_stats()
			SkillSystem.apply_passive_on_start(stat)
		animated_sprite.visible = true
		animated_sprite.modulate = Color.WHITE

		# Wait one physics frame before re-enabling so the player
		# lands on the floor before fall detection can trigger again
		await get_tree().physics_frame
		is_dead = false
		set_physics_process(true)
		return
 
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.visible = false
	set_physics_process(false)
	print("Player Dead")
 
	# Always show death screen — works for traps, enemies, and falls
	if death_screen:
		death_screen.show_death_screen()
	else:
		get_tree().reload_current_scene()


func respawn_at_checkpoint(checkpoint_position: Vector2) -> void:
	print("Respawning at: ", checkpoint_position)

	is_dead = false
	is_falling = false
	is_crouching = false

	global_position = checkpoint_position
	velocity = Vector2.ZERO
	speed_modifier = 1.0
	health = max_health

	if stat != null:
		stat.reset_stats()
		SkillSystem.apply_passive_on_start(stat)
		speed = stat.current_movement

	if collision_shape and collision_shape.shape:
		var normal_shape := RectangleShape2D.new()
		normal_shape.set_size(Vector2(original_height, original_height))
		collision_shape.shape = normal_shape

	animated_sprite.visible = true
	animated_sprite.modulate = Color.WHITE
	setup_character_sprite()

	set_physics_process(true)
	print("Respawn complete.")


func _on_player_respawn(checkpoint_position: Vector2) -> void:
	print("Received respawn signal.")
	respawn_at_checkpoint(checkpoint_position)


func respawn() -> void:
	respawn_at_checkpoint(start_position)


# ============================================================
# DAMAGE / POISON / ENEMY HIT
# ============================================================

func take_damage(amount: int) -> void:
	if is_dead:
		return

	# If shield/stat exist, use Shield logic, otherwise fallback to standard health
	if stat != null:
		CombatSystem.take_damage(stat, amount)
		health = stat.health
	else:
		health -= amount

	print("Player took damage! Health remaining: ", health)

	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

	if stat != null:
		if stat.health <= 0:
			die()
	else:
		if health <= 0:
			die()


func receive_damage(amount: int) -> void:
	take_damage(amount)


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


func apply_speed_modifier(modifier: float) -> void:
	speed_modifier = modifier
	if modifier < 1.0:
		print("Player entered special terrain/vine trap: Slowed down to ", modifier * 100, "%")
	else:
		print("Player left special terrain: Speed restored.")
