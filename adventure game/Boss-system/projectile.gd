extends Area2D

@export var speed = 350
@export var damage := 20
@export var direction = Vector2.LEFT

func _ready():

	add_to_group("boss_projectile")

	body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	print("Projectile hit:", body.name)
	
	if body.is_in_group("player"):

		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()

	elif body is TileMap:
		queue_free()
