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

var player = null
var player_in_range = false
var is_attacking := false

@export var attack_cooldown := 2.0
var attack_timer := 0.0

var fireball_scene = preload("res://fireball.tscn")

@onready var sprite = $AnimatedSprite2D


func _ready():
	randomize()
	health = max_health

	if get_parent().has_node("Player"):
		player = get_parent().get_node("Player")

	sprite.play("IDLE")


func _process(delta):
	if current_state == State.DEAD:
		return

	if player == null:
		return

	if !player_in_range:
		if sprite.animation != "IDLE":
			sprite.play("IDLE")
		is_attacking = false
		attack_timer = 0.0
		return

	attack_timer -= delta

	if attack_timer <= 0 and !is_attacking:
		attack_timer = attack_cooldown
		is_attacking = true
		await attack_pattern()
		is_attacking = false


# ==========================
# DETECTION RANGE
# ==========================

func _on_detection_range_body_entered(body):
	if body == player:
		player_in_range = true


func _on_detection_range_body_exited(body):
	if body == player:
		player_in_range = false
		is_attacking = false
		attack_timer = 0.0
		sprite.play("IDLE")


# ==========================
# DAMAGE
# ==========================

func take_damage(amount):
	if current_state == State.DEAD:
		return

	health -= amount
	sprite.play("HURT")
	await sprite.animation_finished

	if health <= 0:
		await die()
		return

	if health <= 700 and phase == 1:
		await phase_two()
	elif health <= 350 and phase == 2:
		await phase_three()

	sprite.play("IDLE")


# ==========================
# PHASE 2
# ==========================

func phase_two():
	phase = 2
	attack_cooldown = 1.5
	sprite.play("FLYING")
	await sprite.animation_finished
	sprite.play("IDLE")


# ==========================
# PHASE 3
# ==========================

func phase_three():
	phase = 3
	current_state = State.RAGE
	attack_cooldown = 0.8
	sprite.play("FLYING")
	await sprite.animation_finished
	sprite.play("IDLE")


# ==========================
# ATTACK SELECTOR
# ==========================

func attack_pattern():
	if current_state == State.DEAD:
		return

	match phase:
		1:
			if randi() % 2 == 0:
				await fireball_attack()
			else:
				await tail_attack()

		2:
			match randi() % 3:
				0:
					await triple_fireball()
				1:
					await fire_breath()
				2:
					await tail_attack()

		3:
			match randi() % 3:
				0:
					await apocalypse_breath()
				1:
					await charge_attack()
				2:
					await triple_fireball()


# ==========================
# FIREBALL
# ==========================

func fireball_attack():
	if !player_in_range or current_state == State.DEAD:
		return

	sprite.play("ATTACK")
	await get_tree().create_timer(0.4).timeout
	spawn_fireball(0, 20)
	await get_tree().create_timer(0.3).timeout
	sprite.play("IDLE")


func triple_fireball():
	if !player_in_range or current_state == State.DEAD:
		return

	sprite.play("ATTACK")
	await get_tree().create_timer(0.4).timeout
	spawn_fireball(-0.25, 25)
	spawn_fireball(0, 25)
	spawn_fireball(0.25, 25)
	await get_tree().create_timer(0.3).timeout
	sprite.play("IDLE")


# ==========================
# FIRE BREATH
# ==========================

func fire_breath():
	if !player_in_range or current_state == State.DEAD:
		return

	sprite.play("FIRE BREATH")
	for i in range(5):
		if !player_in_range or current_state == State.DEAD:
			break
		spawn_fireball(-0.15, 15)
		spawn_fireball(0, 15)
		spawn_fireball(0.15, 15)
		await get_tree().create_timer(0.15).timeout

	sprite.play("IDLE")


func apocalypse_breath():
	if !player_in_range or current_state == State.DEAD:
		return

	sprite.play("FIRE BREATH")
	for i in range(10):
		if !player_in_range or current_state == State.DEAD:
			break
		spawn_fireball(-0.4, 30)
		spawn_fireball(-0.2, 30)
		spawn_fireball(0, 30)
		spawn_fireball(0.2, 30)
		spawn_fireball(0.4, 30)
		await get_tree().create_timer(0.08).timeout

	sprite.play("IDLE")


# ==========================
# TAIL ATTACK
# ==========================

func tail_attack():
	if !player_in_range or current_state == State.DEAD:
		return

	sprite.play("TAIL ATTACK")
	await get_tree().create_timer(0.3).timeout

	if player != null and player.global_position.distance_to(global_position) < 120:
		if player.has_method("take_damage"):
			match phase:
				1:
					player.take_damage(30)
				2:
					player.take_damage(40)
				3:
					player.take_damage(50)

	await get_tree().create_timer(0.3).timeout
	sprite.play("IDLE")


# ==========================
# CHARGE ATTACK
# ==========================

func charge_attack():
	if !player_in_range or current_state == State.DEAD:
		return

	sprite.play("FLYING")
	var dir = (player.global_position - global_position).normalized()

	for i in range(30):
		if current_state == State.DEAD:
			break
		global_position += dir * 25
		await get_tree().process_frame

	if player != null and global_position.distance_to(player.global_position) < 100:
		if player.has_method("take_damage"):
			player.take_damage(60)

	sprite.play("IDLE")


# ==========================
# SPAWN FIREBALL
# ==========================

func spawn_fireball(angle_offset, damage):
	if player == null:
		return

	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = global_position

	var dir = (player.global_position - global_position).normalized()
	dir = dir.rotated(angle_offset)

	fireball.direction = dir
	fireball.damage = damage
	fireball.speed = 400 + phase * 100


# ==========================
# DEATH
# ==========================

func die():
	current_state = State.DEAD
	is_attacking = false
	sprite.play("DEATH")
	await sprite.animation_finished
	queue_free()
