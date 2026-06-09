# VineTrap.gd
extends Area2D
@export var slow_amount: float = 0.3
@export var trap_duration: float = 2.0
@export var damage_per_tick: int = 5
@export var damage_interval: float = 0.5
var player_caught = false
var damage_timer: float = 0.0
var caught_player = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Timer.wait_time = trap_duration
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	if player_caught and caught_player:
		damage_timer += delta
		if damage_timer >= damage_interval:
			damage_timer = 0.0
			caught_player.take_damage(damage_per_tick)

func _on_body_entered(body):
	if body.is_in_group("player") and not player_caught:
		player_caught = true
		caught_player = body
		body.apply_speed_modifier(slow_amount)
		$AnimatedSprite2D.play("grab")
		$Timer.start()

func _on_body_exited(body):
	if body.is_in_group("player"):
		_release_player(body)

func _on_timer_timeout():
	if caught_player:
		_release_player(caught_player)

func _release_player(body):
	body.apply_speed_modifier(1.0)
	player_caught = false
	caught_player = null
	damage_timer = 0.0
	$AnimatedSprite2D.play("idle")
