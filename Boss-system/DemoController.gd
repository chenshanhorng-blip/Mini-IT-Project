extends CharacterBody2D

## ------------------------------
## 导出变量
## ------------------------------
@export var speed: float = 100.0
@export var patrol_range: float = 150.0
@export var attack_cooldown: float = 1.0
@export var hp: int = 200

## 火球场景
var fireball_scene: PackedScene = preload("res://fireball.tscn")

## ------------------------------
## 状态变量
## ------------------------------
var start_position: Vector2
var moving_right: bool = true
var is_dead: bool = false

## ------------------------------
## 节点
## ------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var hp_label:Label = $HPLabel
## ------------------------------
## 开始
## ------------------------------
func _ready() -> void:
	start_position = global_position
	
	# 播放攻击动画
	sprite.play("ATTACK")
	
	#显示血量
	update_hp_label()
	
	# 设置攻击计时器
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = false
	attack_timer.start()
	
	# 连接信号
	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)

## ------------------------------
## 每帧更新
## ------------------------------
func _physics_process(delta: float) -> void:
	
	if is_dead:
		return
	
	# 一直播放 ATTACK
	if sprite.animation != "ATTACK":
		sprite.play("ATTACK")
	
	_handle_patrol()

## ------------------------------
## 左右巡逻
## ------------------------------
func _handle_patrol() -> void:
	var right_bound = start_position.x + patrol_range
	var left_bound = start_position.x - patrol_range
	
	if moving_right:
		velocity.x = speed
		
		# 你的素材默认朝左
		sprite.flip_h = true
		
		if global_position.x >= right_bound:
			moving_right = false
			
	else:
		velocity.x = -speed
		
		sprite.flip_h = false
		
		if global_position.x <= left_bound:
			moving_right = true
			
	move_and_slide()

## ------------------------------
## 发射火球
## ------------------------------
func shoot_fireball() -> void:
	if fireball_scene == null:
		return
	
	var fireball = fireball_scene.instantiate()
	get_tree().current_scene.add_child(fireball)
	
	# =========================
	# 嘴巴位置偏移（自己可调整）
	# =========================
	var mouth_offset = Vector2(40, 10)
	
	# 朝左时反转 X
	if not moving_right:
		mouth_offset.x = -45
	
	# 从嘴巴位置生成
	fireball.global_position = global_position + mouth_offset
	
	# 火球方向
	var dir = Vector2.RIGHT if moving_right else Vector2.LEFT
	
	# 设置火球方向
	if fireball.has_method("set_fireball_direction"):
		fireball.set_fireball_direction(dir)

## ------------------------------
## 自动攻击
## ------------------------------
func _on_attack_timer_timeout() -> void:
	
	if is_dead:
		return
	
	shoot_fireball()
	
	## ------------------------------
## 更新血量显示
## ------------------------------
func update_hp_label() -> void:
	hp_label.text = "HP: " + str(hp)

## ------------------------------
## 受伤系统
## ------------------------------
func take_damage(damage: int) -> void:
	
	if is_dead:
		return
	
	hp -= damage
	
	#更新血量
	update_hp_label()
	
	print("Enemy HP: ", hp)
	
	# 闪红
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	# 死亡
	if hp <= 0:
		die()

## ------------------------------
## 死亡
## ------------------------------
func die() -> void:
	is_dead = true
	
	velocity = Vector2.ZERO
	
	attack_timer.stop()
	
	#隐藏血量
	hp_label.visible = false
	
	sprite.play("DEATH")
	
	await sprite.animation_finished
	
	queue_free()
