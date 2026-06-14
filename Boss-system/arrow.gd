extends Area2D

@export var speed := 400.0
@export var damage := 20

var direction = Vector2.RIGHT

func _ready():

	print("Arrow Ready")
	print(direction)

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play()

func _process(delta):

	global_position += direction * speed * delta

func _on_body_entered(body):

	if body.is_in_group("player"):

		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
