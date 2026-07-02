extends Area2D

@export var speed = 700
@export var damage := 25
@export var direction = Vector2.LEFT

@onready var sprite = $AnimatedSprite2D
@onready var fireball = $Fireball

func _ready():

	add_to_group("boss_projectile")

	body_entered.connect(_on_body_entered)

	if sprite:
		$Fireball.play()
		sprite.play("Fireball")


func _physics_process(delta):

	position += direction * speed * delta


func set_fireball_direction(dir: Vector2) -> void:

	direction = dir

	if sprite:

		if dir.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false


func _on_body_entered(body):

	print("Fireball hit:", body.name)

	if body.is_in_group("player"):

		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()

	elif body is TileMap:

		queue_free()
