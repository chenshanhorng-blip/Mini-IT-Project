
extends Area2D
 
@export var slow_amount: float = 0.3
@export var trap_duration: float = 2.0
 
var player_caught = false
 
func _ready():
	body_entered.connect(_on_body_entered)
	$Timer.wait_time = trap_duration
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timer_timeout)
 
func _on_body_entered(body):
	if body.is_in_group("player") and not player_caught:
		player_caught = true
		body.apply_speed_modifier(slow_amount)  # ✅ 调用函数，不是直接赋值
		$AnimatedSprite2D.play("grab")
		$Timer.start()
 
func _on_timer_timeout():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.apply_speed_modifier(1.0)      # ✅ 恢复速度
	player_caught = false

# VineTrap.gd
extends Area2D

@export var slow_amount: float = 0.3
@export var trap_duration: float = 2.0
@export var damage_per_tick: int = 5      # 每次扣血量，可在编辑器调整
@export var damage_interval: float = 0.5  # 每隔多少秒扣一次血

var player_caught = false
var damage_timer: float = 0.0
var caught_player = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)    # ← 新增，玩家离开时恢复
	$Timer.wait_time = trap_duration
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	# 持续扣血逻辑
	if player_caught and caught_player:
		damage_timer += delta
		if damage_timer >= damage_interval:
			damage_timer = 0.0
			caught_player.take_damage(damage_per_tick)  # ✅ 扣血

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
	body.apply_speed_modifier(1.0)   # 恢复速度
	player_caught = false
	caught_player = null
	damage_timer = 0.0
	$AnimatedSprite2D.play("idle")
