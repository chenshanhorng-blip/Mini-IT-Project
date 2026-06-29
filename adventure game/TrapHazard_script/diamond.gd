extends Area2D

@onready var gem = $gem
 
signal collected
 
func _ready():
	body_entered.connect(_on_body_entered)
 
var already_collected: bool = false

func _on_body_entered(body):
	if already_collected:
		return
	if body.is_in_group("player") or body.is_in_group("Player"):
		already_collected = true
		gem.play()
		collected.emit()
		queue_free()
