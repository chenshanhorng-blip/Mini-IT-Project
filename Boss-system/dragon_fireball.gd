extends Area2D

var speed = 500.0
var direction = Vector2.LEFT

@onready var sprite = $AnimatedSprite2D
<<<<<<< HEAD
@onready var fireball = $Fireball

func _ready() -> void:
=======


func _ready() -> void:
	$Fireball.play()
>>>>>>> bfa5809f37f3978beea1e15c6cfe180f2c411237
	
	body_entered.connect(_on_body_entered)

	if sprite:
<<<<<<< HEAD
		$Fireball.play()
=======
>>>>>>> bfa5809f37f3978beea1e15c6cfe180f2c411237
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

	if body.name == "Player":

		if body.has_method("take_damage"):
			body.take_damage(1)

		queue_free()

	elif body is TileMap:

		queue_free()
