extends CharacterBody2D

@export var speed: float = 80.0
@export var max_hp: int = 200
@export var attack_distance: float = 55.0   # 💡 近战攻击距离要调小一点（比如50-60），贴身才砍
@export var attack_cooldown: float = 1.2    # 每次挥刀的间隔时间（秒）
@export var melee_damage: int = 15          # 每次近战抓到玩家扣除的血量

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_label: Label = $Hplabel

var hp: int
var target: Node2D = null
var is_dead: bool = false
var is_hurt: bool = false
var can_attack: bool = true

func _ready() -> void:
	hp = max_hp
	add_to_group("enemy")
	sprite.play("IDLE")
	update_hp_label()

func _physics_process(_delta: float) -> void:
	if is_dead or is_hurt:
		return

	if target != null and is_instance_valid(target):
		# 🛠️ 修复不转身：不管是在走动还是停下攻击，每一帧都死死盯着玩家的方向翻转 Sprite
		if target.global_position.x < global_position.x:
			sprite.flip_h = true   # 玩家在左，面向左
		else:
			sprite.flip_h = false  # 玩家在右，面向右

		var distance = global_position.distance_to(target.global_position)

		# 🛠️ 进入近战范围，停下并砍人
		if distance <= attack_distance:
			velocity = Vector2.ZERO
			
			if can_attack:
				perform_melee_attack() # 🌟 触发近战砍人逻辑
			elif sprite.animation != "ATTACK":
				sprite.play("ATTACK")
		
		# 追击玩家
		else:
			var dir = (target.global_position - global_position).normalized()
			velocity = dir * speed
			
			if sprite.sprite_frames.has_animation("Flying"):
				if sprite.animation != "Flying":
					sprite.play("Flying")
			elif sprite.animation != "IDLE":
				sprite.play("IDLE")
	else:
		# 没有目标，原地发呆
		velocity = Vector2.ZERO
		if sprite.animation != "IDLE":
			sprite.play("IDLE")

	move_and_slide()

## 🌟 核心新增：纯近战挥刀伤害
func perform_melee_attack() -> void:
	can_attack = false
	sprite.play("ATTACK")
	
	# 等待 0.3 秒（正好是怪物挥刀动画砍下来的那一瞬间）
	await get_tree().create_timer(0.3).timeout
	
	# 再次检查玩家是否还在攻击范围内，并且自己没死
	if not is_dead and target != null and is_instance_valid(target):
		var current_dist = global_position.distance_to(target.global_position)
		if current_dist <= attack_distance + 15.0: # 稍微给点判定宽容度
			if target.has_method("take_damage"):
				target.take_damage(melee_damage) # 💥 真正让玩家扣血！
				print("⚔️ 恶魔近战砍中了玩家！造成伤害: ", melee_damage)

	# 等待攻击冷却结束
	await get_tree().create_timer(attack_cooldown - 0.3).timeout
	can_attack = true

func update_hp_label() -> void:
	if hp_label:
		hp_label.text = "HP: " + str(hp)



func receive_damage(damage: int) -> void:
	if is_dead:
		return

	hp -= damage
	if hp < 0:
		hp = 0

	update_hp_label()
	print("Enemy took damage. HP remaining: ", hp)

	if hp <= 0:
		die()
		return

	is_hurt = true
	velocity = Vector2.ZERO 
	
	if sprite.sprite_frames.has_animation("Hurt"):
		sprite.play("Hurt")

	await get_tree().create_timer(0.3).timeout

	is_hurt = false
	if not is_dead:
		sprite.play("IDLE")
		
func take_damage(damage: int) -> void:
	receive_damage(damage)

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	update_hp_label()

	if sprite.sprite_frames.has_animation("DEATH"):
		sprite.play("DEATH")
		await sprite.animation_finished 
	else:
		await get_tree().create_timer(1.0).timeout

	queue_free()

# -----------------------------------------------------------------
# 信号连接区域
# -----------------------------------------------------------------
func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower() == "player":
		target = body
		print("Target detected: ", body.name)

func _on_detection_range_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		print("Target lost.")

# _input debug function removed
