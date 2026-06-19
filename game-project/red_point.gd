extends Area2D
 
signal collected
 
func _ready():
	body_entered.connect(_on_body_entered)
 
func _on_body_entered(body):
	print("Body entered diamond: ", body.name, " | groups: ", body.get_groups())
	# Use group check instead of exact name — works for all levels,
	# Player 1, Player 2, and even if node gets renamed
	if body.is_in_group("player") or body.is_in_group("Player"):
		collected.emit()
		queue_free()
