extends CharacterBody2D

# ============================================================
# PLAYER 1 SCRIPT — COMBINED (Boar Princess + Tea Egg Knight)
# Place at: res://script_movement/player1script.gd
# Used by: scene_movement/player1_movement.tscn (BOTH characters)
# ============================================================

@export var speed: float = 200.0
@export var jump_velocity: float = -550.0
@export var crouch_speed: float = 100.0
@export var air_crouch_boost: float = 1.5

<<<<<<< Updated upstream
# --- Health & Speed ---
@export var max_health: int = 100
var health: int = 100
var speed_modifier: float = 1.0  # 1.0 = 正常, 0.3 = 藤蔓减速
=======
@export var max_health: int = 100
var health: int = 100
var speed_modifier: float = 1.0
>>>>>>> Stashed changes

var is_crouching: bool = false
var is_falling: bool = false
var is_dead: bool = false

var original_height: float = 38.0
var crouch_height: float = 20.0
var start_position: Vector2 = Vector2.ZERO
var death_screen = null

<<<<<<< Updated upstream
# --- 仙女圈传送状态 ---
var is_teleporting = false

func _ready():
	start_position = global_position
	health = max_health
=======
var stat: CharacterStat = null
var facing_direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var skill_controller = get_node_or_null("skill_adjust")
@onready var player_hud = get_node_or_null("CanvasLayer/Player")


func _ready() -> void:
	start_position = global_position
	health = max_health
	add_to_group("player")
	add_to_group("Player")
>>>>>>> Stashed changes

	if collision_shape and collision_shape.shape:
		original_height = collision_shape.shape.get_rect().size.y
		crouch_height = original_height * 0.6
<<<<<<< Updated upstream

	# 加载死亡界面
	var death_screen_path = "res://scene/UI/death_screen.tscn"
	if ResourceLoader.exists(death_screen_path):
		death_screen = load(death_screen_path).instantiate()
		add_child(death_screen)
		print("Death screen loaded successfully.")
	else:
		print("Death screen does not exist: ", death_screen_path)

	# 连接复活信号
	if CheckpointManager:
		CheckpointManager.player_respawn.connect(_on_player_respawn)
		print("Respawn signal connected.")

	# 加入玩家群组
	add_to_group("player")
	print("Player added to 'player' group.")

func _physics_process(delta):
	# 坠落状态：失去控制，自动下落
=======

	setup_character_stat()
	setup_skill_system()
	setup_death_screen()
	setup_checkpoint_signal()

	print("Player ready — character: ", stat.character_name if stat else "none")


# ============================================================
# SETUP
# ============================================================

func setup_character_stat() -> void:
	if Global.player1_character != null:
		stat = Global.player1_character
	else:
		stat = Create_Character.Create_Character(Create_Character.CharacterType.BOAR_PRINCESS)
		Global.player1_character = stat

	if stat == null:
		print("ERROR: stat is null")
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
		print("ERROR: skill_adjust node missing in scene")
		return
	if stat == null:
		return

	skill_controller.setup(self, stat)

	if player_hud != null:
		player_hud.setup(stat)
	else:
		print("WARNING: HUD node missing")


func setup_character_sprite() -> void:
	if stat == null:
		return

	if stat.character_name == "Boar Princess":
		# Princess uses the base animations (no suffix)
		animated_sprite.scale = Vector2(0.04, 0.04)
		play_if_exists("idle")

	elif stat.character_name == "Tea Egg Knight":
		# Knight uses _2 suffix animations already in player1_movement.tscn
		animated_sprite.scale = Vector2(0.09, 0.09)
		play_if_exists("idle_2")


func setup_death_screen() -> void:
	var path = "res://scene/UI/death_screen.tscn"
	if ResourceLoader.exists(path):
		death_screen = load(path).instantiate()
		add_child(death_screen)
	else:
		print("Death screen not found: ", path)


func setup_checkpoint_signal() -> void:
	if CheckpointManager:
		if not CheckpointManager.player_respawn.is_connected(_on_player_respawn):
			CheckpointManager.player_respawn.connect(_on_player_respawn)


# ============================================================
# PROCESS — skills
# ============================================================

func _process(_delta: float) -> void:
	if is_dead or stat == null or skill_controller == null:
		return
	skill_controller.handle_input()


# ============================================================
# PHYSICS — movement, jump, crouch, fall, gravity
# ============================================================

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

>>>>>>> Stashed changes
	if is_falling:
		velocity.x = 0
		velocity.y += 80
		move_and_slide()
<<<<<<< Updated upstream
		animated_sprite.play("fall")

=======
		if stat.character_name=="Boar Princess" :
			play_move_animation("fall")
		elif  stat.character_name== "Tea Egg Knight":
			play_move_animation("fall_2")
>>>>>>> Stashed changes
		if position.y > 650:
			die()
		return

<<<<<<< Updated upstream
	# 传送动画期间锁定输入
	if is_teleporting:
		move_and_slide()
		return

	# 下蹲输入
	var crouch_pressed = Input.is_action_pressed("p1_down")

=======
	var crouch_pressed := Input.is_action_pressed("p1_down")
>>>>>>> Stashed changes
	if crouch_pressed:
		if not is_crouching:
			start_crouch()
		if not is_on_floor() and velocity.y > 0:
			velocity.y += 80 * air_crouch_boost * delta
	else:
		if is_crouching and is_on_floor():
			stop_crouch()

<<<<<<< Updated upstream
	# 移动 & 速度计算（含 speed_modifier 用于藤蔓减速）
	var direction = Input.get_axis("p1_left", "p1_right")
	var current_speed = crouch_speed if is_crouching else speed
	current_speed = current_speed * speed_modifier
	velocity.x = direction * current_speed

	# 跳跃
	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	# 重力
=======
	var direction := Input.get_axis("p1_left", "p1_right")
	var current_speed := crouch_speed if is_crouching else speed
	current_speed *= speed_modifier
	velocity.x = direction * current_speed

	if direction != 0:
		facing_direction = Vector2(direction, 0)
		animated_sprite.flip_h = direction < 0

	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

>>>>>>> Stashed changes
	if not is_on_floor():
		velocity.y += 50

	move_and_slide()
	update_animations(direction)

<<<<<<< Updated upstream
	# 坠落触发
=======
>>>>>>> Stashed changes
	if position.y > 600 and not is_falling:
		start_fall()


# ============================================================
# ANIMATIONS — switches between Princess and Knight sets
# ============================================================

func update_animations(direction: float) -> void:
	# Don't interrupt skill/attack animation
	if skill_controller != null and skill_controller.is_attacking:
		return

<<<<<<< Updated upstream
=======
	var is_knight := stat != null and stat.character_name == "Tea Egg Knight"

	if is_crouching:
		play_move_animation("crouch" if not is_knight else "crouch_2")
		return

>>>>>>> Stashed changes
	if not is_on_floor():
		if velocity.y < 0:
			play_move_animation("jump" if not is_knight else "jump_left_2")
		else:
			play_move_animation("fall" if not is_knight else "fall_2")
		return
<<<<<<< Updated upstream

	if direction != 0:
		if direction > 0:
			animated_sprite.play("right_move")
		else:
			animated_sprite.play("left_move")
	else:
		animated_sprite.play("idle")
=======
>>>>>>> Stashed changes

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


func play_if_exists(anim_name: String) -> void:
	if animated_sprite.sprite_frames == null:
		return
	if animated_sprite.sprite_frames.has_animation(anim_name):
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
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
	if is_on_floor() and collision_shape and collision_shape.shape:
		var new_shape := RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, crouch_height))
		collision_shape.shape = new_shape
		position.y += (original_height - crouch_height) / 2


func stop_crouch() -> void:
	if not is_crouching:
		return
<<<<<<< Updated upstream

	is_crouching = false

=======
	is_crouching = false
>>>>>>> Stashed changes
	if collision_shape and collision_shape.shape:
		var new_shape := RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, original_height))
		collision_shape.shape = new_shape
		position.y -= (original_height - crouch_height) / 2


# ============================================================
# FALL / DEATH / RESPAWN
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
	print("Player Dead — Game Over")


func respawn_at_checkpoint(checkpoint_position: Vector2) -> void:
	print("Respawning at: ", checkpoint_position)
	is_dead = false
	is_falling = false
	is_crouching = false
	is_teleporting = false
	global_position = checkpoint_position
	velocity = Vector2.ZERO
<<<<<<< Updated upstream

	# 复活时重置所有状态
	health = max_health
	speed_modifier = 1.0
=======
	speed_modifier = 1.0
	health = max_health

	if stat != null:
		stat.reset_stats()
		SkillSystem.apply_passive_on_start(stat)
		speed = stat.current_movement
>>>>>>> Stashed changes

	if collision_shape and collision_shape.shape:
		var normal_shape := RectangleShape2D.new()
		normal_shape.set_size(Vector2(original_height, original_height))
		collision_shape.shape = normal_shape

<<<<<<< Updated upstream
=======
	animated_sprite.visible = true
	animated_sprite.modulate = Color.WHITE
	setup_character_sprite()
>>>>>>> Stashed changes
	set_physics_process(true)
	print("Respawn complete.")


func _on_player_respawn(checkpoint_position: Vector2) -> void:
	respawn_at_checkpoint(checkpoint_position)


func respawn() -> void:
	respawn_at_checkpoint(start_position)

<<<<<<< Updated upstream
# Added teleport_to function
func teleport_to(pos: Vector2) -> void:
	global_position = pos
=======

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

	print("Player took damage. HP remaining: ", health)

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

>>>>>>> Stashed changes

# --- New Damage & Slow Interfaces Called By Trap ---
# ============================================================
# 陷阱接口
# ============================================================

# 【藤蔓绊脚】减速 / 恢复速度
func apply_speed_modifier(modifier: float) -> void:
	speed_modifier = modifier
	if modifier < 1.0:
<<<<<<< Updated upstream
		print("Player entered vine trap: Slowed down to ", modifier * 100, "%")
	else:
		print("Player escaped vine trap: Speed restored.")

# 【藤蔓绊脚 / 毒沼】受到伤害
func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage! Health remaining: ", health)

	# 受伤闪红特效
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		die()

# 【仙女圈传送】传送到目标位置
func teleport_to(target_pos: Vector2) -> void:
	is_teleporting = true
	velocity = Vector2.ZERO

	# 传送闪烁特效
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 0), 0.15)  # 淡出
	
	await tween.finished
	global_position = target_pos                                                  # 移动位置
	
	tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.15)  # 淡入

	await tween.finished
	is_teleporting = false
	print("Player teleported to: ", target_pos)
=======
		print("Player slowed.")
	else:
		print("Player speed restored.")
>>>>>>> Stashed changes
