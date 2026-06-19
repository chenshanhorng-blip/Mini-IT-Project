extends Area2D

signal collected

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Body entered diamond: ", body.name, " | groups: ", body.get_groups())
	# Use group check instead of exact name match — works for Player1,
	# Player2, and even if Godot renames the node (e.g. "Player1@2")
	if body.is_in_group("player") or body.is_in_group("Player"):
		collected.emit()
		queue_free()
