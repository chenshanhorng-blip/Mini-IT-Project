extends Area2D

signal collected

func _ready():
	monitoring = true
	body_entered.connect(_on_body_entered)
	print("Diamond ready: ", name)
	print("Diamond monitoring: ", monitoring)
	print("Diamond collision mask: ", collision_mask)

func _on_body_entered(body):
	print("Body entered diamond: ", body.name)
	if body is CharacterBody2D:
		collected.emit()
		queue_free()
