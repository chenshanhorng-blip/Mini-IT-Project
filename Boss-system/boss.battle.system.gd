
extends CharacterBody2D

enum State { IDLE, RAGE, DEAD }

var max_health = 1000
var health = 1000
var phase = 1
var current_state = State.IDLE

var attack_cooldown = 2.0
var attack_timer = 0.0

@export var fireball_scene:PackedScene
var player


func _ready():
	randomize()
	player = get_parent().get_node("Player")

	$BossHealthBar.max_value = max_health
	$BossHealthBar.value = health


func _process(delta):

	if current_state == State.DEAD:
		return

	attack_timer -= delta

	if attack_timer <= 0:
		await attack_pattern()
		attack_timer = attack_cooldown


func take_damage(amount):
	health -= amount
	$BossHealthBar.value = health

	if randi() % 3 == 0:
		await speak("You dare hit me?!How dare you!!!!I want to kill you!")

	if health <= 700 and phase == 1:
		await phase_two()

	if health <= 350 and phase == 2:
		await phase_three()

	if health <= 0:
		await die()


func attack_pattern():

	var move = randi() % 4

	if phase == 1:
		match move:
			0: await fireball()
			1: await ground_smash()
			2: await fireball()
			3: await ground_smash()

	elif phase == 2:
		match move:
			0: await fire_breath()
			1: await fireball()
			2: await charge_attack()
			3: await ground_smash()

	elif phase == 3:
		match move:
			0: await fire_breath()
			1: await meteor_attack()
			2: await apocalypse_fire()
			3: await fire_breath()


func fireball():
	await speak("Burn!")
	spawn_fire(0)

func fire_breath():
	await speak("BURN EVERYTHING!!!")

	for i in range(8):
		spawn_fire(-0.3)
		spawn_fire(0)
		spawn_fire(0.3)
		await get_tree().create_timer(0.2).timeout


func spawn_fire(angle_offset):
	var fb = fireball_scene.instantiate()
	get_parent().add_child(fb)
	fb.position = $FireballSpawn.global_position

	var dir = (player.position - fb.position).normalized()
	dir = dir.rotated(angle_offset)

	fb.direction = dir
	fb.speed = 400 + (phase * 100)


func ground_smash():
	await speak("CRUSH!!!")

	await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(0.3).timeout

	if player.position.distance_to(position) < 120:
		player.take_damage(30)

func charge_attack():
	await speak("You cannot escape!")


func meteor_attack():
	await speak("Meteor fall!")


func apocalypse_fire():
	await speak("End of all!!!")

func speak(text):
	$BossDialogue.text = ""
	$BossDialogue.visible = true

	for c in text:
		$BossDialogue.text += c
		await get_tree().create_timer(0.03).timeout

	await get_tree().create_timer(1.2).timeout
	$BossDialogue.visible = false


# ================= Evolution =================
func phase_two():
	phase = 2
	attack_cooldown = 1.5
	await speak("You dare challenge me?")


func phase_three():
	phase = 3
	current_state = State.RAGE
	attack_cooldown = 0.8
	await speak("Feel my TRUE POWER!!!")

func die():
	current_state = State.DEAD
	await speak("Impossible...")
	queue_free()
