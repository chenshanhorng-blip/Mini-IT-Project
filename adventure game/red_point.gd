extends Area2D

@onready var gem = $gem

signal collected

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Body entered diamond: ", body.name, " | groups: ", body.get_groups())

	if body.is_in_group("player") or body.is_in_group("Player"):

		collected.emit()

		gem.play()

		$CollisionShape2D.set_deferred("disabled", true)

		await gem.finished

		queue_free()
