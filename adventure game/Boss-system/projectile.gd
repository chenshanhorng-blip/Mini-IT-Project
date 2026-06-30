extends Area2D

var speed = 350
var direction = Vector2.LEFT

func _physics_process(delta):

	position += direction * speed * delta


func _on_body_entered(body):

	if body.name == "Player":
		queue_free()

	elif body is TileMap:
		queue_free()
