extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = -550.0
@export var crouch_speed = 80.0  # 蹲下时的速度

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

# 蹲下状态
var is_crouching = false
var original_height = 32.0  # 原始碰撞高度（根据你的实际大小调整）
var crouch_height = 16.0    # 蹲下碰撞高度

# 掉落状态
var is_falling = false
var start_position = Vector2.ZERO

func _ready():
	start_position = global_position
	# 获取原始碰撞高度
	if collision_shape and collision_shape.shape:
		original_height = collision_shape.shape.get_rect().size.y

func _physics_process(delta):
	# 掉落状态：只能下落，不能控制
	if is_falling:
		velocity.x = 0
		velocity.y += 80
		move_and_slide()
		animated_sprite.play("jump")
		return
	
	# 蹲下输入（按下下键或 S）
	if Input.is_action_just_pressed("p1_down") and is_on_floor():
		start_crouch()
	elif Input.is_action_just_released("p1_down"):
		stop_crouch()
	
	# 正常移动
	var direction = Input.get_axis("p1_left", "p1_right")
	
	# 蹲下时减速
	if is_crouching:
		direction *= 0.5
	
	velocity.x = direction * (crouch_speed if is_crouching else speed)

	# 跳跃（蹲下时不能跳）
	if Input.is_action_just_pressed("p1_up") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	# 重力
	if not is_on_floor():
		velocity.y += 50

	move_and_slide()

	# 动画
	if is_crouching:
		animated_sprite.play("down")  # 用你的 down 动画
	elif direction != 0:
		if direction > 0:
			animated_sprite.play("right_move")
		else:
			animated_sprite.play("left_move")
	else:
		animated_sprite.play("idle")
	
	# 掉落重置
	if position.y > 600 and not is_falling:
		start_fall()

# 开始蹲下
func start_crouch():
	if is_crouching:
		return
	is_crouching = true
	if collision_shape and collision_shape.shape:
		var new_shape = RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, crouch_height))
		collision_shape.shape = new_shape
		position.y += (original_height - crouch_height) / 2

# 结束蹲下
func stop_crouch():
	if not is_crouching:
		return
	is_crouching = false
	if collision_shape and collision_shape.shape:
		var new_shape = RectangleShape2D.new()
		new_shape.set_size(Vector2(original_height, original_height))
		collision_shape.shape = new_shape
		position.y -= (original_height - crouch_height) / 2

# 开始掉落（被陷阱调用）
func start_fall():
	if is_falling:
		return
	is_falling = true
	velocity = Vector2.ZERO

# 复活回起点
func respawn():
	is_falling = false
	is_crouching = false
	global_position = start_position
	velocity = Vector2.ZERO
	# 确保碰撞恢复
	stop_crouch()
