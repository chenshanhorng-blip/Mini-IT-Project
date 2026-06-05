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
var is_attacking = false


func _ready():
	hp = max_hp
	update_hp_label()
	sprite.play("WALK")


func _physics_process(_delta):

	if is_dead or is_hurt or is_attacking:
		move_and_slide()
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

			attack()

		# 追擊
		else:

			var dir = (target.global_position - global_position).normalized()

			velocity = dir * speed

			if sprite.animation != "WALK":
				sprite.play("WALK")

	else:

		velocity = Vector2.ZERO

		if sprite.animation != "WALK":
			sprite.play("WALK")

	move_and_slide()


func attack():

	if is_attacking:
		return

	is_attacking = true

	velocity = Vector2.ZERO

	sprite.play("ATTACK")

	await sprite.animation_finished

	is_attacking = false


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

	velocity = Vector2.ZERO

	sprite.play("HURT")

	await sprite.animation_finished

	is_hurt = false


func die():

	is_dead = true

	velocity = Vector2.ZERO

	update_hp_label()

	$CollisionShape2D.disabled = true

	sprite.play("DEATH")

	await sprite.animation_finished

	queue_free()


func _on_detection_range_body_entered(body):

	if body.name == "player":
		target = body


func _on_detection_range_body_exited(body):

	if body == target:
		target = null


# 测试按空格扣血
func _input(event):

	if event.is_action_pressed("ui_accept"):
		take_damage(20)
