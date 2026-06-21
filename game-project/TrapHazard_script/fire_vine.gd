extends Area2D

@export var damage_per_second: float = 15.0
@export var tick_rate: float = 0.5

var bodies_in_vine = []
var timer: Timer

func _ready():
	$AnimatedSprite2D.play("default")
	if not body_entered.connect(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.connect(_on_body_exited):
		body_exited.connect(_on_body_exited)

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = tick_rate
	timer.timeout.connect(_deal_damage)
	timer.start()

func _on_body_entered(body):
	if body.is_in_group("player"):
		bodies_in_vine.append(body)
		print("Player touched vine!")

func _on_body_exited(body):
	bodies_in_vine.erase(body)

func _deal_damage():
	for body in bodies_in_vine:
		if is_instance_valid(body):
			body.take_damage(int(damage_per_second * tick_rate))
