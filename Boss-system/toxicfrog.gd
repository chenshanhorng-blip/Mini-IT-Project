extends CharacterBody2D

# =========================
# 基本设置
# =========================
@export var speed : float = 80.0
@export var patrol_distance : float = 200.0

@export var max_hp : int = 100
var hp : int

# =========================
# 状态
# =========================
var direction := -1
var start_x := 0.0

var player = null

var attacking = false
var dead = false
var attack_cooldown = false

# =========================
# 节点
# =========================
@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var hp_label = $hplabel

# =========================
# 初始化
# =========================
func _ready():

	hp = max_hp

	start_x = global_position.x

	update_hp()

# =========================
# 物理更新
# =========================
func _physics_process(delta):

	# 死亡
	if dead:
		return

	# 自动寻找玩家
	if player == null:
		player = get_tree().get_first_node_in_group("player")

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

	# 巡逻方向
	sprite.flip_h = direction < 0

	# 巡逻动画
	if sprite.animation != "HOP":
		sprite.play("HOP")

	# 左边界
	if direction == -1 and global_position.x <= start_x - patrol_distance:
		direction = 1

	# 右边界
	elif direction == 1 and global_position.x >= start_x + patrol_distance:
		direction = -1

	# =====================
	# 撞到玩家才攻击
	# =====================
	if player != null and attack_area.overlaps_body(player):

		velocity.x = 0

		# 朝向玩家
		if player.global_position.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

		if not attack_cooldown:
			attack()

	move_and_slide()

# =========================
# 攻击
# =========================
func attack():

	if attacking or dead or attack_cooldown:
		return

	attacking = true
	attack_cooldown = true

	velocity.x = 0

	# 播放攻击动画
	sprite.play("ATTACK")

	# =====================
	# 玩家扣血
	# =====================
	if player != null:

		if player.has_method("take_damage"):
			player.take_damage(10)

	# 攻击持续时间
	await get_tree().create_timer(0.5).timeout

	attacking = false

	# 攻击冷却
	await get_tree().create_timer(1.0).timeout

	attack_cooldown = false

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

# =========================
# 更新血量
# =========================
func update_hp():

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
