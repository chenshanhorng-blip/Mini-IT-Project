extends CharacterBody2D

enum State {
	DIALOGUE,
	IDLE,
	RAGE,
	DEAD
}

@export var max_health := 1000

var health := 1000
var phase := 1
var current_state = State.DIALOGUE

var intro_done = false
var phase2_dialogue = false
var death_dialogue = false

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
@onready var fire_breath_sound_2 = $Firebreathsound2
@onready var projectile_sound = $ProjectileSound
@onready var ground_smash_sound = $GroundSmashSound
@onready var dialogue_point = $DialoguePoint

func _ready():

	hp_label.text = "BOSS HP"

	update_hp()

	sprite.play("IDLE")

	start_intro()

func start_intro():

	current_state = State.DIALOGUE

	var dialogue = preload("res://Boss-system/projectile.tscn").instantiate()

	add_child(dialogue)

	dialogue.dialogue_array = [
		"For hundreds of years, I have guarded this key.",
		"Many sought it.",
		"All of them died.",
		"Will you be any different?"
	]

	await dialogue.tree_exited

	start_battle()


func update_hp():

	print("UPDATE HP")

	hp_label.text = "HP: " + str(health)

func start_battle():

	current_state = State.IDLE

	while is_inside_tree():

		if current_state == State.DEAD:
			return

		if current_state == State.DIALOGUE:
			await get_tree().process_frame
			continue

		await attack_pattern()

		if current_state == State.DEAD:
			return

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
		return

	elif health <= 300 and phase == 2:
		await phase_three()


func phase_two():

	phase = 2

	current_state = State.DIALOGUE

	sprite.play("FLYING")

	var dialogue = preload("res://Boss-system/dialogue_prototype.tscn").instantiate()

	add_child(dialogue)

	dialogue.dialogue_array = [
		"Impossible...",
		"A human has wounded me?",
		"Witness my true power!"
	]

	await dialogue.tree_exited

	current_state = State.IDLE


func phase_three():

	phase = 3

	current_state = State.DIALOGUE

	sprite.play("FLYING")

	var dialogue = preload("res://Boss-system/projectile.tscn").instantiate()

	add_child(dialogue)

	dialogue.dialogue_array = [
		"You refuse to fall...",
		"Then I shall burn everything!"
	]

	await dialogue.tree_exited

	current_state = State.RAGE


func attack_pattern():

	if current_state == State.DIALOGUE:
		return

	if current_state == State.DEAD:
		return

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

	var dir = Vector2(-1, 0.5).normalized()

	dir = dir.rotated(angle_offset)

	if fireball.has_method("set_fireball_direction"):
		fireball.set_fireball_direction(dir)

	fireball.speed = 700


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


# =====================
# GROUND SMASH
# =====================

func tail_attack():
	
	ground_smash_sound.play()

	sprite.play("GROUND SMASH")

	await get_tree().create_timer(0.4).timeout

	await screen_shake()


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

	current_state = State.DIALOGUE

	hp_label.visible = false

	var dialogue = preload("res://Boss-system/projectile.tscn").instantiate()

	add_child(dialogue)

	dialogue.dialogue_array = [
		"You have proven your strength.",
		"Take the key.",
		"Leave this forest..."
	]

	await dialogue.tree_exited

	current_state = State.DEAD

	boss_death_sound.play()

	sprite.play("DEATH")

	await sprite.animation_finished

	queue_free()
	
func _input(event):

	if event.is_action_pressed("ui_accept"):

		take_damage(50)
