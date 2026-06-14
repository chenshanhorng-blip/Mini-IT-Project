extends Area2D

signal collected

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Body entered diamond: ", body.name)
	if body.name == "Player1":
		collected.emit()
		queue_free()
