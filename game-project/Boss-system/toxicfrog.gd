extends CharacterBody2D
# =========================
# 基本设置
# =========================
@export var speed : float = 80.0
@export var patrol_distance : float = 200.0
@export var max_hp : int = 100
@export var attack_damage : int = 10
@export var gravity : float = 980.0
var hp : int
# =========================
# 状态
# =========================
var direction := -1
var start_x := 0.0
var player = null
var player_stat : CharacterStat = null
var attacking = false
var dead = false
var attack_cooldown = false
# =========================
# 节点
# =========================
@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var detect_area = $DetectArea
@onready var hp_label = $hplabel
# =========================
# 初始化
# =========================
func _ready():
	hp = max_hp
	start_x = global_position.x
	update_hp()
	add_to_group("enemy")

	if Global.player1_character != null:
		player_stat = Global.player1_character

	if attack_area:
		attack_area.monitoring = true
		attack_area.monitorable = true

	if detect_area:
		detect_area.monitoring = true
		detect_area.monitorable = true

	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

	# DEBUG: print collision/motion setup once at start
	print("=== FROG READY DEBUG ===")
	print("motion_mode: ", motion_mode)
	print("collision_layer: ", collision_layer)
	print("collision_mask: ", collision_mask)
	print("starting global_position: ", global_position)
	for child in get_children():
		if child is CollisionShape2D:
			print("Body CollisionShape2D - disabled: ", child.disabled, " shape: ", child.shape, " position: ", child.position)

# =========================
# 物理更新
# =========================
func _physics_process(delta):
	if dead:
		return

	# Apply gravity so frog stays grounded on platforms
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# DEBUG: print every frame so we can see exactly what's happening
	print("is_on_floor: ", is_on_floor(), " | velocity.y: ", velocity.y, " | global_position: ", global_position)

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player != null and player_stat == null:
			if Global.player1_character != null:
				player_stat = Global.player1_character

	# =====================
	# 攻击状态
	# =====================
	if attacking:
		velocity.x = 0
		move_and_slide()
		return

	# =====================
	# 左右巡逻
	# =====================
	velocity.x = direction * speed
	sprite.flip_h = direction < 0

	if sprite.animation != "HOP":
		sprite.play("HOP")

	if direction == -1 and global_position.x <= start_x - patrol_distance:
		direction = 1
	elif direction == 1 and global_position.x >= start_x + patrol_distance:
		direction = -1

	# =====================
	# 撞到玩家才攻击
	# =====================
	if player != null and attack_area != null:
		var overlapping = attack_area.overlaps_body(player)
		if overlapping and not attack_cooldown:
			velocity.x = 0
			sprite.flip_h = player.global_position.x < global_position.x
			attack()

	move_and_slide()

	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != player and not collider.is_in_group("player"):
				var normal = collision.get_normal()
				if abs(normal.x) > 0.5:
					direction *= -1
				break

# =========================
# 攻击
# =========================
func attack():
	if attacking or dead or attack_cooldown:
		return
	attacking = true
	attack_cooldown = true
	velocity.x = 0

	sprite.stop()
	sprite.play("ATTACK")

	if player_stat != null:
		CombatSystem.take_damage(player_stat, attack_damage)
		print("Frog attacked player via CombatSystem for ", attack_damage)
	elif player != null and player.has_method("take_damage"):
		player.take_damage(attack_damage)
		print("Frog attacked player via take_damage() for ", attack_damage)

	await get_tree().create_timer(1.0).timeout
	if attacking:
		attacking = false
		if not dead:
			sprite.play("HOP")

	await get_tree().create_timer(0.6).timeout
	attack_cooldown = false

func _on_animation_finished():
	if sprite.animation == "ATTACK" and attacking:
		attacking = false
		if not dead:
			sprite.play("HOP")
	elif sprite.animation == "HURT" and not dead:
		sprite.play("HOP")

# =========================
# 受伤
# =========================
func take_damage(damage):
	if dead:
		return
	hp -= damage
	update_hp()
	if hp <= 0:
		die()
		return
	sprite.play("HURT")

func receive_damage(damage: int) -> void:
	take_damage(damage)

func update_hp() -> void:
	if hp_label:
		hp_label.text = str(hp)

# =========================
# 死亡
# =========================
func die():
	dead = true
	attacking = true
	velocity.x = 0
	sprite.play("EXPLOSION")
	await get_tree().create_timer(0.8).timeout
	queue_free()
