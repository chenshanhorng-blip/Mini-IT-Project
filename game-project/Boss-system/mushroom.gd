extends Node2D

# =========================
# 参数
# =========================
@export var patrol_speed = 100.0
@export var patrol_distance = 200.0
@export var attack_distance = 50.0

# =========================
# 血量
# =========================
@export var max_hp = 100
var hp = 100

# =========================
# 变量
# =========================
var start_x
var direction = 1
var player = null
var is_attacking = false

# =========================
# 节点
# =========================
@onready var sprite = $AnimatedSprite2D
@onready var detect_area = $Area2D
@onready var hp_label = $hplabel

# =========================
# 初始化
# =========================
func _ready():

	start_x = position.x

	hp = max_hp

	update_hp_label()

	sprite.play("PATROL")

	# 玩家检测
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)

# =========================
# 主循环
# =========================
func _process(delta):

	# 血量显示跟随更新
	update_hp_label()

	# =====================================
	# 有玩家
	# =====================================
	if player != null:

		var distance = global_position.distance_to(player.global_position)

		# =====================
		# 攻击
		# =====================
		if distance <= attack_distance:

			is_attacking = true

			sprite.play("ATTACK")

			print("攻击玩家")

			# 停止移动
			return

		# =====================
		# 玩家太远
		# =====================
		else:

			is_attacking = false

	# =====================================
	# 没玩家 / 玩家离开
	# =====================================
	sprite.play("PATROL")

	position.x += direction * patrol_speed * delta

	# 到右边
	if position.x >= start_x + patrol_distance:

		direction = -1

		sprite.flip_h = false

	# 到左边
	elif position.x <= start_x - patrol_distance:

		direction = 1

		sprite.flip_h = true

# =========================
# 玩家进入范围
# =========================
func _on_body_entered(body):

	if body.is_in_group("Player"):

		player = body

		print("发现玩家")

# =========================
# 玩家离开范围
# =========================
func _on_body_exited(body):

	if body == player:

		player = null

		is_attacking = false

		print("玩家离开")

# =========================
# 更新血量显示
# =========================
func update_hp_label():

	hp_label.text = str(hp)

# =========================
# 受伤
# =========================
func take_damage(damage):

	hp -= damage
	sprite.play("HIT")
	update_hp_label()

	print("怪物受伤: ", damage)

	# 死亡
	if hp <= 0:
		sprite.play("DIE")
		queue_free()
