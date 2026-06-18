extends CharacterBody2D

@export var speed := 80.0
@export var max_hp := 200
@export var attack_distance := 100.0

@onready var sprite = $AnimatedSprite2D
@onready var hp_label: Label = $Hplabel

var hp : int
var target = null
var is_dead = false
var is_hurt = false


func _ready():
	hp = max_hp
	sprite.play("IDLE")
	update_hp_label()


func _physics_process(_delta):

	if is_dead or is_hurt:
		return

	if target != null and is_instance_valid(target):

		# 面向玩家
		if target.global_position.x < global_position.x:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

		var distance = global_position.distance_to(target.global_position)

		# 攻击
		if distance <= attack_distance:

			velocity = Vector2.ZERO

			if sprite.animation != "ATTACK":
				sprite.play("ATTACK")

		# 追击
		else:

			var dir = (target.global_position - global_position).normalized()
			velocity = dir * speed

			if sprite.animation != "IDLE":
				sprite.play("IDLE")

	else:

		velocity = Vector2.ZERO

		if sprite.animation != "IDLE":
			sprite.play("IDLE")

	move_and_slide()


func update_hp_label():
	hp_label.text = "HP: " + str(hp)


func take_damage(damage):

	if is_dead:
		return

	hp -= damage

	if hp < 0:
		hp = 0

	update_hp_label()

	print("Enemy HP:", hp)

	if hp <= 0:
		die()
		return

	is_hurt = true

	sprite.play("HURT")

	await get_tree().create_timer(0.3).timeout

	is_hurt = false
	sprite.play("IDLE")

	if !is_dead:
		sprite.play("IDLE")


func die():

	is_dead = true

	velocity = Vector2.ZERO

	update_hp_label()

	sprite.play("DEATH")

	await get_tree().create_timer(1.0).timeout

	queue_free()


func _on_detection_range_body_entered(body):

	if body.name == "player":
		target = body


func _on_detection_range_body_exited(body):

	if body == target:
		target = null


# 测试用，按空格扣20血
func _input(event):

	if event.is_action_pressed("ui_accept"):
		take_damage(20)
