extends Area2D

@onready var gem = $gem
 
# Signal sent when the gem is collected
signal collected
 
func _ready():
	body_entered.connect(_on_body_entered)
 
# Prevent duplicate collection
var already_collected: bool = false

func _on_body_entered(body):
	if already_collected:
		return

	# Detect whether the player collects the gem
	if body.is_in_group("player") or body.is_in_group("Player"):
		already_collected = true
		gem.play()

		# Notify other systems that the gem has been collected
		collected.emit()

		# Remove the collected gem from the scene
		queue_free()
