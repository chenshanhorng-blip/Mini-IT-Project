extends CharacterBody2D

signal boss_defeated

# 战斗/剧情状态(来自代码3)
enum State {
	DIALOGUE,
	IDLE,
	RAGE,
	DEAD
}

# 飞行动作状态(来自代码2)
enum FlightState {
	TAKEOFF,
	ATTACK,
	LANDING,
	COOLDOWN
}

@export var max_health := 1000
@export var fly_height: float = 80.0
@export var flight_speed: float = 150.0
@export var ground_smash_damage: int = 20
@export var fireball_damage := 25
@export var fire_breath_damage := 15
@export var tail_projectile_damage := 20

var health := 1000
var phase := 1
var current_state = State.DIALOGUE
var flight_state = FlightState.TAKEOFF

var intro_done = false
var phase2_dialogue = false
var death_dialogue = false

var original_pos_y: float
var player_node: Node2D

var fireball_scene = preload("res://Boss-system/dragon_fireball.tscn")
var breath_scene = preload("res://Boss-system/projectile.tscn")
var tail_scene = preload("res://Boss-system/projectile.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var mouth = $MouthMarker
@onready var tail_marker = $TailMarker
@onready var camera = get_viewport().get_camera_2d()
@onready var hp_label = $HPLabel
@onready var fireball_attack_sound = $FireballAttackSound
@onready var fire_breath_sound = $FireBreathSound
@onready var boss_death_sound = $BossDeathSound
@onready var fire_breath_sound_2 = $FireBreathSound2
@onready var projectile_sound = $ProjectileSound
@onready var ground_smash_sound = $GroundSmashSound
@onready var dialogue_point = $DialoguePoint
@onready var attack_area: Area2D = $AttackArea
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready():

	add_to_group("enemy")
	add_to_group("Boss")

	player_node = get_tree().get_first_node_in_group("player")

	original_pos_y = global_position.y

	hp_label.text = "BOSS HP"

	update_hp()

	sprite.play("IDLE")

	if attack_area:
		attack_area.monitoring = false
		attack_area.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))

	start_intro()


func get_dialogue_layer() -> Node:
	var layer = get_tree().root.find_child("DialogueLayer", true, false)

	if layer == null:
		push_error("DialogueLayer not found!")
		return null

	return layer


func start_intro():

	current_state = State.DIALOGUE

	var dialogue = preload("res://Boss-system/dialogue_prototype.tscn").instantiate()
	 
	print(dialogue)
	print(dialogue.scene_file_path)
	print(dialogue.get_script())
	
	var layer = get_dialogue_layer()

	if layer == null:
		return

	layer.add_child(dialogue)

	await get_tree().process_frame   # ← 加这一行
	
	print(dialogue.get_children())

	dialogue.dialogue_array = [
		"For hundreds of years, I have guarded this key.",
		"Many sought it.",
		"All of them died.",
		"Will you be any different?"
	]

	dialogue.start()

	await dialogue.tree_exited

	start_battle()


func update_hp():

	print("UPDATE HP")

	hp_label.text = "HP: " + str(health)


# =====================
# 主循环:剧情/阶段状态驱动飞行循环
# =====================

func start_battle():

	current_state = State.IDLE

	while is_inside_tree():

		if current_state == State.DEAD:
			return

		if current_state == State.DIALOGUE:
			await get_tree().process_frame
			continue

		await flight_cycle()

		if current_state == State.DEAD:
			return


func flight_cycle():

	await takeoff_phase()

	if current_state == State.DEAD:
		return

	await attack_phase()

	if current_state == State.DEAD:
		return

	await landing_phase()

	if current_state == State.DEAD:
		return

	await cooldown_phase()


# ---------------- 飞行逻辑(来自代码2) ----------------

func takeoff_phase() -> void:

	flight_state = FlightState.TAKEOFF

	sprite.play("FLYING")

	if collision:
		collision.disabled = true

	var target_pos = Vector2(global_position.x, original_pos_y - fly_height)
	var duration = fly_height / flight_speed

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished


func attack_phase() -> void:

	flight_state = FlightState.ATTACK

	# 攻击选择逻辑完全不变,按原来的phase随机池走
	await attack_pattern()


func landing_phase() -> void:

	flight_state = FlightState.LANDING

	var target_pos = Vector2(global_position.x, original_pos_y)
	var duration = fly_height / flight_speed

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished

	velocity = Vector2.ZERO

	if collision:
		collision.disabled = false


func cooldown_phase() -> void:

	flight_state = FlightState.COOLDOWN

	sprite.play("IDLE")

	await get_tree().create_timer(1.0).timeout


# =====================
# 受伤 / 死亡
# =====================

func take_damage(amount):

	if current_state == State.DEAD:
		return

	health -= amount

	update_hp()

	print("HP:", health)

	modulate = Color.RED

	await get_tree().create_timer(0.1).timeout

	modulate = Color.WHITE

	if health <= 0:
		await die()
		return

	sprite.play("HURT")

	await sprite.animation_finished

	if health <= 700 and phase == 1:
		await phase_two()
		return

	elif health <= 300 and phase == 2:
		await phase_three()


func receive_damage(amount: int) -> void:
	# 兼容 CombatSystem 用 receive_damage 调用伤害的写法
	take_damage(amount)


func phase_two():

	phase = 2
	
	# 第二阶段提升伤害
	fireball_damage = 35
	fire_breath_damage = 25
	tail_projectile_damage = 30
	ground_smash_damage = 35

	current_state = State.DIALOGUE

	sprite.play("FLYING")

	var dialogue = preload("res://Boss-system/dialogue_prototype.tscn").instantiate()

	get_tree().current_scene.get_node("DialogueLayer").add_child(dialogue)

	dialogue.dialogue_array = [
		"Impossible...",
		"A human has wounded me?",
		"Witness my true power!"
	]

	dialogue.start()

	await dialogue.tree_exited

	sprite.play("IDLE")

	current_state = State.IDLE


func phase_three():

	phase = 3

	# 第三阶段再提升伤害
	fireball_damage = 50
	fire_breath_damage = 40
	tail_projectile_damage = 45
	ground_smash_damage = 50

	current_state = State.DIALOGUE

	sprite.play("FLYING")

	var dialogue = preload("res://Boss-system/dialogue_prototype.tscn").instantiate()

	get_tree().current_scene.get_node("DialogueLayer").add_child(dialogue)

	dialogue.dialogue_array = [
		"You refuse to fall...",
		"Then I shall burn everything!"
	]

	dialogue.start()

	await dialogue.tree_exited

	current_state = State.RAGE


func die():

	current_state = State.DIALOGUE

	hp_label.visible = false

	var dialogue = preload("res://Boss-system/dialogue_prototype.tscn").instantiate()

	get_tree().current_scene.get_node("DialogueLayer").add_child(dialogue)

	dialogue.dialogue_array = [
		"You have proven your strength.",
		"Take the key.",
		"Leave this forest..."
	]

	dialogue.start()

	await dialogue.tree_exited

	current_state = State.DEAD

	boss_defeated.emit()

	boss_death_sound.play()

	sprite.play("DEATH")

	await sprite.animation_finished

	queue_free()


# =====================
# 攻击选择(完全不变)
# =====================

func attack_pattern():

	if current_state == State.DIALOGUE:
		return

	if current_state == State.DEAD:
		return

	match phase:

		1:

			match randi() % 5:

				0:
					await fireball_attack()

				1:
					await fireball_attack()

				2:
					await tail_attack()

				3:
					await fireball_attack()

				4:
					await tail_attack()

		2:

			match randi() % 4:

				0:
					await fireball_attack()

				1:
					await fire_breath()

				2:
					await tail_attack()

				3:
					await tail_projectile()

		3:

			match randi() % 5:

				0:
					await apocalypse_breath()

				1:
					await fireball_attack()

				2:
					await triple_fireball()

				3:
					await tail_attack()

				4:
					await tail_projectile()


# =====================
# FIREBALL
# =====================

func fireball_attack():

	fireball_attack_sound.play()

	sprite.play("FIREBALL ATTACK")

	await get_tree().create_timer(0.45).timeout

	spawn_fireball(0)

	await get_tree().create_timer(0.3).timeout


func triple_fireball():

	sprite.play("FIREBALL ATTACK")

	await get_tree().create_timer(0.45).timeout

	spawn_fireball(-0.2)
	spawn_fireball(0)
	spawn_fireball(0.2)

	await get_tree().create_timer(0.3).timeout


func spawn_fireball(angle_offset):

	var fireball = fireball_scene.instantiate()

	get_tree().current_scene.add_child(fireball)

	fireball.global_position = mouth.global_position

	# 瞄准玩家
	var dir = (player_node.global_position - mouth.global_position).normalized()

	# 加一点角度偏移（三连火球会用到）
	dir = dir.rotated(angle_offset)

	if fireball.has_method("set_fireball_direction"):
		fireball.set_fireball_direction(dir)

	fireball.speed = 700
	fireball.damage = fireball_damage


# =====================
# FIRE BREATH
# =====================

func fire_breath():

	fire_breath_sound.play()
	fire_breath_sound_2.play()

	sprite.play("FIRE BREATH")

	await get_tree().create_timer(0.4).timeout

	for i in range(5):

		spawn_breath()

		await get_tree().create_timer(0.15).timeout


func apocalypse_breath():

	fire_breath_sound.play()

	sprite.play("FIRE BREATH")

	await get_tree().create_timer(0.3).timeout

	for i in range(10):

		spawn_breath()

		await get_tree().create_timer(0.08).timeout


func spawn_breath():

	var breath = breath_scene.instantiate()

	get_tree().current_scene.add_child(breath)

	breath.global_position = mouth.global_position

	breath.direction = Vector2.LEFT

	breath.speed = 350
	
	breath.damage = fire_breath_damage


# =====================
# GROUND SMASH(尾巴攻击,加了碰撞伤害)
# =====================

func tail_attack():

	ground_smash_sound.play()

	sprite.play("GROUND SMASH")

	await get_tree().create_timer(0.4).timeout

	if attack_area:
		attack_area.monitoring = true

	await screen_shake()

	if attack_area:
		attack_area.monitoring = false


# =====================
# TAIL PROJECTILE
# =====================

func tail_projectile():

	projectile_sound.play()

	sprite.play("TAIL ATTACK")

	await get_tree().create_timer(0.7).timeout

	spawn_tail()


func spawn_tail():

	var tail = tail_scene.instantiate()

	get_tree().current_scene.add_child(tail)

	tail.global_position = tail_marker.global_position

	tail.direction = Vector2.LEFT

	tail.speed = 700
	
	tail.damage = tail_projectile_damage

# =====================
# SCREEN SHAKE
# =====================

func screen_shake():

	if camera == null:
		return

	camera.offset.y = 12

	await get_tree().create_timer(0.08).timeout

	camera.offset.y = -12

	await get_tree().create_timer(0.08).timeout

	camera.offset = Vector2.ZERO


# =====================
# AttackArea 碰撞信号
# =====================

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(ground_smash_damage)


func _input(event):
	if event.is_action_pressed("ui_accept"):

		take_damage(100)
