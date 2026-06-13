extends CharacterBody2D

# ============================================================
# MUSHROOM ENEMY
# - Patrols left/right
# - Attacks player on contact via CombatSystem
# - take_damage() called by player skill area → enemy dies
# - receive_damage() alias so skill_part system works too
# ============================================================

@export var patrol_speed: float = 80.0
@export var patrol_distance: float = 200.0
@export var attack_damage: int = 10
@export var max_hp: int = 80

var hp: int
var start_x: float = 0.0
var direction: int = 1

var player_node = null
var player_stat: CharacterStat = null

var dead: bool = false
var attack_cooldown: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var hp_label = $hplabel
# Mushroom scene uses Area2D (not AttackArea)
@onready var attack_area = $Area2D


func _ready() -> void:
	hp = max_hp
	start_x = global_position.x
	update_hp_label()
	add_to_group("enemy")

	# Grab player stat from Global
	if Global.player1_character != null:
		player_stat = Global.player1_character

	# Connect area signal for contact detection
	if attack_area:
		if not attack_area.body_entered.is_connected(_on_area_body_entered):
			attack_area.body_entered.connect(_on_area_body_entered)
		if not attack_area.body_exited.is_connected(_on_area_body_exited):
			attack_area.body_exited.connect(_on_area_body_exited)

	sprite.play("WALK")


func _physics_process(_delta: float) -> void:
	if dead:
		return

	# Auto-find player
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player")
		if player_node != null and player_stat == null:
			if Global.player1_character != null:
				player_stat = Global.player1_character

	# Patrol
	velocity.x = direction * patrol_speed
	sprite.flip_h = direction < 0

	if global_position.x >= start_x + patrol_distance:
		direction = -1
	elif global_position.x <= start_x - patrol_distance:
		direction = 1

	move_and_slide()

	if sprite.animation != "WALK":
		sprite.play("WALK")


func _on_area_body_entered(body) -> void:
	if dead:
		return
	if body.is_in_group("player"):
		player_node = body
		if player_stat == null and Global.player1_character != null:
			player_stat = Global.player1_character
		do_attack()


func _on_area_body_exited(body) -> void:
	if body == player_node:
		attack_cooldown = false


func do_attack() -> void:
	if attack_cooldown or dead:
		return
	attack_cooldown = true
	sprite.play("ATTACK")

	# Deal damage through CombatSystem
	if player_stat != null:
		CombatSystem.take_damage(player_stat, attack_damage)
		print("Mushroom attacked player for ", attack_damage)
	elif player_node != null and player_node.has_method("take_damage"):
		player_node.take_damage(attack_damage)

	await get_tree().create_timer(1.2).timeout
	attack_cooldown = false
	if not dead:
		sprite.play("WALK")


# Called by player skill area hitting this enemy
func take_damage(damage: int) -> void:
	if dead:
		return
	hp -= damage
	update_hp_label()
	print("Mushroom took ", damage, " damage. HP:", hp)

	if hp <= 0:
		die()
		return

	sprite.play("HIT")
	await get_tree().create_timer(0.3).timeout
	if not dead:
		sprite.play("WALK")

# Alias — skill_part system calls receive_damage()
func receive_damage(damage: int) -> void:
	take_damage(damage)


func update_hp_label() -> void:
	if hp_label:
		hp_label.text = str(hp)


func die() -> void:
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	sprite.play("DIE")
	print("Mushroom died!")
	await get_tree().create_timer(0.8).timeout
	queue_free()
