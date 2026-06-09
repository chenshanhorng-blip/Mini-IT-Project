extends CharacterBody2D

# =====================================================
# TOXIC FROG ENEMY
# Integrated with Princess Game's CombatSystem.
# Damage to player routes through CombatSystem so
# shield, passives, and death signals all work.
# =====================================================

@export var speed: float = 80.0
@export var patrol_distance: float = 200.0
@export var attack_damage: int = 10

@export var max_hp: int = 100
var hp: int

var direction := -1
var start_x := 0.0

var player_node = null           # Player CharacterBody2D node
var player_stat: CharacterStat = null  # From Global.player1_character

var attacking = false
var dead = false
var attack_cooldown = false

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var hp_label = $hplabel


func _ready():
	hp = max_hp
	start_x = global_position.x
	update_hp()

	# Connect to player stat from Global
	if Global.player1_character != null:
		player_stat = Global.player1_character


func _physics_process(delta):
	if dead:
		return

	# Auto-find player by group if not set
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player")
		if player_node != null and player_stat == null and Global.player1_character != null:
			player_stat = Global.player1_character

	if attacking:
		velocity.x = 0
		move_and_slide()
		return

	# Patrol
	velocity.x = direction * speed
	sprite.flip_h = direction < 0

	if sprite.animation != "HOP":
		sprite.play("HOP")

	if direction == -1 and global_position.x <= start_x - patrol_distance:
		direction = 1
	elif direction == 1 and global_position.x >= start_x + patrol_distance:
		direction = -1

	# Attack when overlapping player
	if player_node != null and attack_area.overlaps_body(player_node):
		velocity.x = 0
		sprite.flip_h = player_node.global_position.x < global_position.x

		if not attack_cooldown:
			attack()

	move_and_slide()


func attack():
	if attacking or dead or attack_cooldown:
		return

	attacking = true
	attack_cooldown = true
	velocity.x = 0
	sprite.play("ATTACK")

	# Deal damage through CombatSystem
	if player_stat != null:
		CombatSystem.take_damage(player_stat, attack_damage)
		print("ToxicFrog attacked player for ", attack_damage)
	elif player_node != null and player_node.has_method("receive_damage"):
		player_node.receive_damage(attack_damage)

	await get_tree().create_timer(0.5).timeout
	attacking = false

	await get_tree().create_timer(1.0).timeout
	attack_cooldown = false


func take_damage(damage):
	if dead:
		return

	hp -= damage
	update_hp()

	if hp <= 0:
		die()
		return

	sprite.play("HURT")


func update_hp():
	if hp_label:
		hp_label.text = str(hp)


func die():
	dead = true
	attacking = true
	velocity.x = 0
	sprite.play("EXPLOSION")

	await get_tree().create_timer(0.8).timeout
	queue_free()
