extends CharacterBody2D

# ============================================================
# PLAYER 2 SCRIPT — MULTIPLAYER
# Uses p2_left / p2_right / p2_up / p2_down input actions
# Reads from Global.player2_character
# Has same movement, death, respawn as Player 1
# Skill system: basic attack / skill1 / skill2 / ultimate
# via p2_basic_attack / p2_skill1 / p2_skill2 / p2_ultimate
# ============================================================

@export var jump_velocity: float = -550.0
@export var crouch_speed: float  = 100.0
@export var air_crouch_boost: float = 1.5

var speed: float        = 200.0
var speed_modifier: float = 1.0
var health: int         = 100
var max_health: int     = 100

var is_crouching: bool  = false
var is_falling: bool    = false
var is_dead: bool       = false

var original_height: float = 38.0
var crouch_height: float   = 20.0
var start_position: Vector2 = Vector2.ZERO
var crouch_sprite_offset: float = 0.0
var death_screen = null

var stat: CharacterStat = null

# Correct scales matching player2_movement.tscn
const KNIGHT_SCALE   =Vector2(0.08069446, 0.08385417)
const PRINCESS_SCALE =  Vector2(0.05069446, 0.05385417)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D  = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var skill_controller = get_node_or_null("skill_adjust")
@onready var player_hud = get_node_or_null("CanvasLayer/Player")
@onready var skill_ui = get_node_or_null("CanvasLayer/skill ui")


func _ready() -> void:
	start_position = global_position
	add_to_group("player")
	add_to_group("Player")

	if collision_shape and collision_shape.shape:
		original_height = collision_shape.shape.get_rect().size.y
		crouch_height   = original_height * 0.6

	setup_character_stat()
	setup_skill_system()
	setup_death_screen()
	setup_checkpoint_signal()
	setup_camera()

	print("Player 2 ready — character:", stat.character_name if stat else "none")


# ============================================================
# SETUP
# ============================================================

func setup_character_stat() -> void:
	if Global.player2_character != null:
		stat = Global.player2_character
	else:
		# Fallback if no character was picked for P2
		stat = Create_Character.Create_Character(Create_Character.CharacterType.TEA_EGG_KNIGHT)
		Global.player2_character = stat

	if stat == null:
		return

	SkillSystem.apply_passive_on_start(stat)
	speed = stat.current_movement

	if not stat.health_depleted.is_connected(on_player_dead):
		stat.health_depleted.connect(on_player_dead)

	setup_character_sprite()
	print("P2 using:", stat.character_name)
	stat.print_stat()


func setup_character_sprite() -> void:
	if stat == null:
		return
	if stat.character_name == "Tea Egg Knight":
		animated_sprite.scale = KNIGHT_SCALE
		play_if_exists("idle_2")
	elif stat.character_name == "Boar Princess":
		animated_sprite.scale = PRINCESS_SCALE
		play_if_exists("idle")


func setup_skill_system() -> void:
	if skill_controller == null:
		print("ERROR: Player 2 skill_adjust node missing — basic attack/skills will not work")
		return
	if stat == null:
		print("ERROR: Player 2 stat is null, skill system cannot setup")
		return

	# player_id = 2 makes skill_adjust read p2_basic_attack / p2_skill1 /
	# p2_skill2 / p2_ultimate instead of Player 1's action names
	skill_controller.setup(self, stat, 2)

	if player_hud != null:
		player_hud.setup(stat)
	else:
		print("WARNING: Player 2 HUD node missing")

	# Tell the skill UI buttons (cooldown display) to read Player 2's stat
	if skill_ui != null:
		skill_ui.set_player_id(2)
	else:
		print("WARNING: Player 2 skill UI node missing")


func setup_death_screen() -> void:
	var path = "res://scene/UI/death_screen.tscn"
	if ResourceLoader.exists(path):
		death_screen = load(path).instantiate()
		add_child(death_screen)
	else:
		print("P2 death screen not found:", path)


func setup_checkpoint_signal() -> void:
	if CheckpointManager:
		if not CheckpointManager.player_respawn.is_connected(_on_player_respawn):
			CheckpointManager.player_respawn.connect(_on_player_respawn)


func setup_camera() -> void:
	# In multiplayer the camera on Player 2 should be disabled
	# so only Player 1's camera follows. A shared camera can be
	# added to the level scene instead.
	if Global.game_mode == "multiplayer":
		camera.enabled = false
	else:
		camera.enabled = true


# ============================================================
# PROCESS — skill input (basic attack, skill1, skill2, ultimate)
# ============================================================

func _process(_delta: float) -> void:
	if is_dead:
		return
	if skill_controller != null and stat != null:
		skill_controller.handle_input()


# ============================================================
# PHYSICS — p2_ input actions
# ============================================================

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_falling:
		velocity.x  = 0
		velocity.y += 80
		move_and_slide()
		play_if_exists("fall_2" if is_knight() else "fall")
		if position.y > 650:
			die()
		return

	# Crouch
	var crouch_pressed := Input.is_action_pressed("p2_down")
	if crouch_pressed:
		if not is_crouching:
			start_crouch()
		if not is_on_floor() and velocity.y > 0:
			velocity.y += 80 * air_crouch_boost * delta
	else:
		if is_crouching and is_on_floor():
			stop_crouch()

	# Horizontal
	var dir_x := Input.get_axis("p2_left", "p2_right")
	var current_speed := crouch_speed if is_crouching else speed
	current_speed *= speed_modifier
	velocity.x = dir_x * current_speed

	if dir_x != 0:
		animated_sprite.flip_h = dir_x < 0

	# Jump
	if Input.is_action_just_pressed("p2_up") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	# Gravity
	if not is_on_floor():
		velocity.y += 50

	move_and_slide()
	update_animations(dir_x)

	if position.y > 600 and not is_falling:
		start_fall()


# ============================================================
# ANIMATIONS
# ============================================================

func is_knight() -> bool:
	return stat != null and stat.character_name == "Tea Egg Knight"


func update_animations(direction: float) -> void:
	# Don't interrupt basic attack / skill / ultimate animation
	if skill_controller != null and skill_controller.is_attacking:
		return

	if is_crouching:
		play_if_exists("down")
		animated_sprite.scale=Vector2(0.04003032,0.04003032)
		if is_knight():
			play_if_exists("down_left_2")
		return

	if not is_on_floor():
		play_if_exists(("jump_left_2" if is_knight() else "jump") if velocity.y < 0 else ("fall_2" if is_knight() else "fall"))
		return

	if direction > 0:
		play_if_exists("right_move_2" if is_knight() else "right_move")
	elif direction < 0:
		play_if_exists("left_move_2" if is_knight() else "left_move")
	else:
		play_if_exists("idle_2" if is_knight() else "idle")


func play_if_exists(anim_name: String) -> void:
	if animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)


# ============================================================
# CROUCH
# ============================================================

func start_crouch() -> void:
	if is_crouching:
		return
	is_crouching = true
	if is_on_floor() and collision_shape and collision_shape.shape:
		var s := RectangleShape2D.new()
		s.set_size(Vector2(original_height, crouch_height))
		collision_shape.shape = s
		crouch_sprite_offset = (original_height - crouch_height) / 2
		position.y += crouch_sprite_offset
		animated_sprite.position.y -= crouch_sprite_offset


func stop_crouch() -> void:
	if not is_crouching:
		return
	is_crouching = false
	if collision_shape and collision_shape.shape:
		var s := RectangleShape2D.new()
		s.set_size(Vector2(original_height, original_height))
		collision_shape.shape = s
		crouch_sprite_offset = (original_height - crouch_height) / 2
		position.y += crouch_sprite_offset
		animated_sprite.position.y += crouch_sprite_offset


# ============================================================
# FALL / DEATH / RESPAWN
# ============================================================

func start_fall() -> void:
	if is_falling:
		return
	print("Player 2 started falling.")
	is_falling = true


func die() -> void:
	if is_dead:
		return
	print("Player 2 died.")
	on_player_dead()
	if death_screen:
		death_screen.show_death_screen()
	else:
		get_tree().reload_current_scene()


func on_player_dead() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.visible = false
	set_physics_process(false)
	print("Player 2 Dead")


func respawn_at_checkpoint(checkpoint_position: Vector2) -> void:
	print("P2 respawning at:", checkpoint_position)
	is_dead     = false
	is_falling  = false
	is_crouching = false
	global_position = checkpoint_position
	velocity    = Vector2.ZERO
	speed_modifier = 1.0
	health      = max_health

	if stat != null:
		stat.reset_stats()
		SkillSystem.apply_passive_on_start(stat)
		speed = stat.current_movement

	if collision_shape and collision_shape.shape:
		var s := RectangleShape2D.new()
		s.set_size(Vector2(original_height, original_height))
		collision_shape.shape = s

	animated_sprite.visible  = true
	animated_sprite.modulate = Color.WHITE
	setup_character_sprite()

	# Make sure a skill/attack frozen mid-animation doesn't block input after respawn
	if skill_controller != null:
		skill_controller.is_attacking = false
		if skill_controller.has_method("hide_all_effects"):
			skill_controller.hide_all_effects()

	set_physics_process(true)
	print("P2 respawn complete.")


func _on_player_respawn(checkpoint_position: Vector2) -> void:
	respawn_at_checkpoint(checkpoint_position)


func respawn() -> void:
	respawn_at_checkpoint(start_position)


# ============================================================
# DAMAGE
# ============================================================

func take_damage(amount: int) -> void:
	if is_dead:
		return

	if stat != null:
		CombatSystem.take_damage(stat, amount)
		health = stat.health
	else:
		health -= amount
		if health <= 0:
			die()

	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED,   0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

	print("P2 took damage. HP:", health)


func receive_damage(amount: int) -> void:
	take_damage(amount)


func apply_speed_modifier(modifier: float) -> void:
	speed_modifier = modifier
