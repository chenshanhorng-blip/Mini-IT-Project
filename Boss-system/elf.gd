extends CharacterBody2D

@export var hp := 100
@export var attack_cooldown := 1.5

var arrow_scene: PackedScene = preload("res://arrow.tscn")

var player = null
var dead = false

@onready var sprite = $AnimatedSprite2D
@onready var hp_label = $HPLabel
@onready var attack_timer = $AttackTimer

func _ready():
	update_hp()
	sprite.play("IDLE")

func _physics_process(_delta):

	if dead:
		return

	if player:

		if player.global_position.x < global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

		if attack_timer.is_stopped():
			attack()

	else:
		if sprite.animation != "IDLE":
			sprite.play("IDLE")

func attack():

	if dead:
		return

	attack_timer.start(attack_cooldown)

	sprite.play("ATTACK")

	spawn_arrow()

func spawn_arrow():

	var arrow = arrow_scene.instantiate()

	get_tree().current_scene.add_child(arrow)

	if sprite.flip_h:
		arrow.global_position = global_position + Vector2(-60, -10)
		arrow.direction = Vector2.LEFT
	else:
		arrow.global_position = global_position + Vector2(60, -10)
		arrow.direction = Vector2.RIGHT

func take_damage(damage):

	if dead:
		return

	hp -= damage

	update_hp()

	if hp <= 0:
		die()
		return

	sprite.play("HURT")

func die():

	dead = true

	sprite.play("DEATH")

	await sprite.animation_finished

	queue_free()

func update_hp():
	hp_label.text = str(hp)

func _on_detection_range_body_entered(body):

	if body.is_in_group("player"):
		player = body

func _on_detection_range_body_exited(body):

	if body == player:
		player = null
