extends CharacterBody2D

enum State { TAKEOFF, ATTACK, LANDING, COOLDOWN }

@export var speed: float = 150.0
@export var fly_height: float = 80.0
@export var health: int = 1000
@export var damage_cooldown: float = 1.5

var current_state: State = State.TAKEOFF
var player_node: Node2D
var fireball_scene: PackedScene = preload("res://Boss-system/dragon_fireball.tscn")
var can_attack: bool = true
var original_pos_y: float

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea   # 保留攻击范围节点

func _ready():
	player_node = get_tree().get_first_node_in_group("player")
	original_pos_y = global_position.y
	print("🐉 Dragon ready")
	attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))
	attack_area.monitoring = false   # 默认关闭
	attack_loop()

func _physics_process(delta):
	if current_state == State.TAKEOFF or current_state == State.LANDING:
		move_and_slide()

func attack_loop() -> void:
	while health > 0:
		match current_state:
			State.TAKEOFF:
				await takeoff_phase()
			State.ATTACK:
				await attack_phase()
			State.LANDING:
				await landing_phase()
			State.COOLDOWN:
				await cooldown_phase()

# ---------------- 飞行逻辑 ----------------

func takeoff_phase() -> void:
	print("🐉 Dragon taking off (flying upward)")
	sprite.play("FLYING")
	var target_pos = global_position + Vector2(0, -fly_height)
	var duration = fly_height / speed
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	current_state = State.ATTACK

func attack_phase() -> void:
	print("🐉 Dragon attacking in the air")
	sprite.play("STANDBY")

	# 攻击池：Ground Smash 出现概率降低
	var attacks = [
		fireball, fire_breath, tail_attack,
		fireball, fire_breath, tail_attack,
		ground_smash
	]
	var attack_func = attacks[randi() % attacks.size()]
	attack_func.call()

	await get_tree().create_timer(2.0).timeout
	current_state = State.LANDING

func landing_phase() -> void:
	print("🐉 Dragon landing (going down)")
	sprite.play("GROUND SMASH")
	var target_pos = global_position + Vector2(0, fly_height)
	var duration = fly_height / speed
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	velocity = Vector2.ZERO
	collision.disabled = false
	await get_tree().create_timer(3.0).timeout
	collision.disabled = true
	current_state = State.COOLDOWN

func cooldown_phase() -> void:
	print("🐉 Dragon cooldown on ground")
	sprite.play("STANDBY")
	await get_tree().create_timer(3.0).timeout
	current_state = State.TAKEOFF

# ---------------- 攻击技能 ----------------

func fireball():
	if not can_attack:
		return
	can_attack = false
	print("🐉 Dragon launched fireball!")
	var fb = fireball_scene.instantiate()
	add_child(fb)
	if fb.has_method("launch"):
		fb.launch(
			(player_node.global_position - global_position).normalized(),
			$MouthMarker.global_position
		)
	await get_tree().create_timer(damage_cooldown).timeout
	can_attack = true

func fire_breath():
	if not can_attack:
		return
	can_attack = false
	print("🔥 Dragon uses Fire Breath!")
	sprite.play("FIRE BREATH")
	attack_area.monitoring = true
	await sprite.animation_finished
	attack_area.monitoring = false
	await get_tree().create_timer(damage_cooldown).timeout
	can_attack = true

func ground_smash():
	if not can_attack:
		return
	can_attack = false
	print("💥 Dragon uses Ground Smash!")

	var target_pos = Vector2(player_node.global_position.x, player_node.global_position.y - 100)
	var timeout = 0
	while global_position.distance_to(target_pos) > 10 and timeout < 120:
		var dir = (target_pos - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
		await get_tree().process_frame
		timeout += 1

	var smash_pos = Vector2(target_pos.x, original_pos_y)
	timeout = 0
	while global_position.distance_to(smash_pos) > 10 and timeout < 120:
		var dir_down = (smash_pos - global_position).normalized()
		velocity = dir_down * speed
		move_and_slide()
		await get_tree().process_frame
		timeout += 1

	velocity = Vector2.ZERO
	sprite.play("GROUND SMASH")
	collision.disabled = false

	if player_node and player_node.has_method("take_damage"):
		player_node.take_damage(20)

	await get_tree().create_timer(3.0).timeout
	collision.disabled = true
	await sprite.animation_finished

	# ✅ 攻击后退后一大步，根据朝向决定方向
	var retreat_distance = 450
	var retreat_dir = Vector2.ZERO
	if sprite.flip_h:   # 如果朝右
		retreat_dir = Vector2(-retreat_distance, 0)   # 往左退
	else:               # 如果朝左
		retreat_dir = Vector2(retreat_distance, 0)    # 往右退

	var retreat_pos = global_position + retreat_dir
	var retreat_tween = create_tween()
	retreat_tween.tween_property(self, "global_position", retreat_pos, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await retreat_tween.finished

	await get_tree().create_timer(damage_cooldown).timeout
	can_attack = true

	current_state = State.LANDING

func tail_attack():
	if not can_attack:
		return
	can_attack = false
	print("🌀 Dragon uses Tail Attack!")
	sprite.play("TAIL ATTACK")
	attack_area.monitoring = true
	await sprite.animation_finished
	attack_area.monitoring = false
	await get_tree().create_timer(damage_cooldown).timeout
	can_attack = true

# ---------------- 受伤与死亡 ----------------

func take_damage(amount: int):
	health -= amount
	print("🐉 Dragon took damage:", amount, "HP:", health)
	if health <= 0:
		die()

func die():
	print("🐉 Dragon Dead")
	sprite.play("DEATH")
	collision.disabled = true

# ---------------- Area2D 信号 ----------------

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(15)
