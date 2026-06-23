extends CharacterBody2D

enum State {
	IDLE,
	RAGE,
	DEAD
}

@export var max_health := 1000

var health := 1000
var phase := 1
var current_state = State.IDLE

var fireball_scene = preload("res://dragon_fireball.tscn")
var breath_scene = preload("res://projectile.tscn")
var tail_scene = preload("res://projectile.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var mouth = $MouthMarker
@onready var tail_marker = $TailMarker
@onready var camera = get_viewport().get_camera_2d()
@onready var hp_label = $HPLabel


func _ready():

	hp_label.text = "BOSS HP"

	update_hp()

	sprite.play("IDLE")

	call_deferred("start_battle")


func update_hp():

	print("UPDATE HP")

	hp_label.text = "HP: " + str(health)


func start_battle():

	while current_state != State.DEAD:

		await attack_pattern()

		await get_tree().create_timer(1.0).timeout


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

	elif health <= 300 and phase == 2:
		await phase_three()


func phase_two():

	phase = 2

	print("PHASE 2")

	sprite.play("FLYING")

	await sprite.animation_finished


func phase_three():

	phase = 3

	current_state = State.RAGE

	print("PHASE 3")

	sprite.play("FLYING")

	await sprite.animation_finished


func attack_pattern():

	match phase:

		1:

			match randi() % 3:

				0:
					await fireball_attack()

				1:
					await tail_attack()

				2:
					await tail_projectile()

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

	var dir = Vector2(-1, 0.5).normalized()

	dir = dir.rotated(angle_offset)

	if fireball.has_method("set_fireball_direction"):
		fireball.set_fireball_direction(dir)

	fireball.speed = 700


# =====================
# FIRE BREATH
# =====================

func fire_breath():

	sprite.play("FIRE BREATH")

	await get_tree().create_timer(0.4).timeout

	for i in range(5):

		spawn_breath()

		await get_tree().create_timer(0.15).timeout


func apocalypse_breath():

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


# =====================
# GROUND SMASH
# =====================

func tail_attack():

	sprite.play("GROUND SMASH")

	await get_tree().create_timer(0.4).timeout

	await screen_shake()


# =====================
# TAIL PROJECTILE
# =====================

func tail_projectile():

	sprite.play("TAIL ATTACK")

	await get_tree().create_timer(0.7).timeout

	spawn_tail()


func spawn_tail():

	var tail = tail_scene.instantiate()

	get_tree().current_scene.add_child(tail)

	tail.global_position = tail_marker.global_position

	tail.direction = Vector2.LEFT

	tail.speed = 700


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
# DEATH
# =====================

func die():

	current_state = State.DEAD

	hp_label.visible = false

	sprite.play("DEATH")

	await get_tree().create_timer(1.5).timeout

	queue_free()
