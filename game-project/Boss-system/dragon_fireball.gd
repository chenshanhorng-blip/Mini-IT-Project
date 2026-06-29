extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO
var is_flying: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	visible = false
	monitoring = false
	monitorable = false
	if collision:
		collision.disabled = true

	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)
	print("🔥 Fireball ready")

func launch(dir: Vector2, start_pos: Vector2):
	# 设置初始位置和方向
	global_position = start_pos
	direction = dir.normalized()
	is_flying = true
	visible = true
	monitoring = true
	monitorable = true
	
	if collision:
		collision.disabled = false

	# 播放火球动画
	if sprite:
		sprite.play("default")  # 确保有一个名为 "default" 的动画

	print("🔥 Fireball launched at:", global_position, " direction:", direction)

	# 定时销毁（如果没碰到玩家）
	await get_tree().create_timer(2.0).timeout
	reset_state()

func _physics_process(delta):
	if is_flying:
		position += direction * speed * delta

func reset_state():
	is_flying = false
	visible = false
	monitoring = false
	monitorable = false
	if collision:
		collision.disabled = true
	if sprite:
		sprite.stop()
	print("🔥 Fireball reset")

func _on_body_entered(body):
	print("🔥 Fireball body_entered triggered with:", body.name)
	if body.is_in_group("player"):
		print("🔥 Fireball hit player! Damage = 10")
		if body.has_method("take_damage"):
			body.take_damage(10)
		reset_state()
