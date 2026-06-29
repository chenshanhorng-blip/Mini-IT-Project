extends CharacterBody2D

## ------------------------------
## Export Variables
## ------------------------------
@export var speed: float = 100.0
@export var patrol_range: float = 150.0
@export var attack_cooldown: float = 1.0
@export var hp: int = 200

## Fireball scene preload path (Updated to correct folder structure)
var fireball_scene: PackedScene = preload("res://Sprite/fireball.tscn")

## ------------------------------
## State Variables
## ------------------------------
var start_position: Vector2
var moving_right: bool = true
var is_dead: bool = false

## ------------------------------
## Onready Nodes
## ------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var hp_label: Label = $HPLabel

## ------------------------------
## Initialization
## ------------------------------
func _ready() -> void:
	start_position = global_position
	sprite.play("ATTACK")
	add_to_group("enemy")
	update_hp_label()
	
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = false
	attack_timer.start()
	
	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)

## ------------------------------
## Physics Frame Update
## ------------------------------
func _physics_process(delta: float) -> void:
	# Stop all behaviors and animations if the enemy is dead
	if is_dead:
		return
		
	if sprite.animation != "ATTACK":
		sprite.play("ATTACK")
		
	_handle_patrol()

## ------------------------------
## Patrol Logic (Left and Right)
## ------------------------------
func _handle_patrol() -> void:
	var right_bound = start_position.x + patrol_range
	var left_bound = start_position.x - patrol_range

	if moving_right:
		velocity.x = speed
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
## Shoot Fireball Mechanism
## ------------------------------
func shoot_fireball() -> void:
	if fireball_scene == null:
		return

	var fireball = fireball_scene.instantiate()
	
	# Spawn fireball as a sibling node to ensure correct coordinate reference system
	get_parent().add_child(fireball)

	# Calculate horizontal offset based on facing direction
	var mouth_offset = Vector2(40,10)
	if not moving_right:
		mouth_offset.x = -45

	fireball.global_position = global_position + mouth_offset

	# Send direction vectors to fireball scene
	var dir = Vector2.RIGHT if moving_right else Vector2.LEFT
	if fireball.has_method("set_fireball_direction"):
		fireball.set_fireball_direction(dir)

## ------------------------------
## Timer Callback for Auto Attack
## ------------------------------
func _on_attack_timer_timeout() -> void:
	if is_dead:
		return
	shoot_fireball()

## ------------------------------
## Update HP UI Label
## ------------------------------
func update_hp_label() -> void:
	if hp_label:
		hp_label.text = "HP: " + str(hp)

## ------------------------------
## Damage System (Enemy takes damage)
## ------------------------------
func receive_damage(damage: int) -> void:
	if is_dead:
		return

	hp -= damage
	update_hp_label()
	print("Enemy HP: ", hp)

	# Visual flash red feedback when hit
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

	if hp <= 0:
		die()

## ------------------------------
## Death Core Logic
## ------------------------------
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	attack_timer.stop()
	
	if hp_label:
		hp_label.visible = false
		
	sprite.play("DEATH")
	await sprite.animation_finished
	queue_free()
