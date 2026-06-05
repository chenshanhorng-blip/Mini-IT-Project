extends Area2D

var speed = 450.0
# 默认让它有个方向，后面会被恶魔脚本改掉
var direction = Vector2.RIGHT 

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	# 自动连接碰撞信号
	body_entered.connect(_on_body_entered)
	# 确保火球一出生就播放飞行的动画
	if sprite:
		sprite.play("Fireball") 

func _physics_process(delta):
	# 火球沿直线飞行
	position += direction * speed * delta

## 核心功能：接收恶魔传过来的方向，并自动翻转图片帧
func set_fireball_direction(dir: Vector2) -> void:
	direction = dir
	
	if sprite:
		if dir.x < 0:
			sprite.flip_h = true  # 向左飞，图片帧水平翻转
		else:
			sprite.flip_h = false # 向右飞，图片帧保持原样
			
func _on_body_entered(body):
	# 简单的碰撞检测
	if body.name == "Player":
		print("打中玩家了！")
		if body.has_method("take_damage"):
			body.take_damage(1) # 触发玩家受伤
		queue_free() # 火球消失
		
	elif body is TileMap:
		queue_free() # 撞墙消失
