extends Area2D

var ready_to_kill = false

func _ready():

	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	await get_tree().process_frame
	ready_to_kill = true
	
func _on_body_entered(body):

	if !ready_to_kill:
		print("Ignore first frame")
		return

	print("===================")
	print("Trap:", name)
	print("Body:", body.name)

	if body.has_method("die"):
		body.die()
