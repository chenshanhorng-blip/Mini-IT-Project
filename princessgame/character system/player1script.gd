extends CharacterBody2D

@export var speed = 300.0
@onready var sprite = $Sprite2D
var stat: CharacterStat = null
func receive_damage(damage:int) -> void:
	if stat == null:
		return
	
	CombatSystem.take_damage(stat, damage)
	stat.print_stat()
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_J:
			receive_damage(10)
func _ready():
	if Global.player1_character != null:
		stat = Global.player1_character
		speed = stat.current_movement
		print("Using character:", stat.character_name)
		print("Speed:", stat.current_movement)
		if stat.character_name == "Boar Princess":
			sprite.texture = load("res://picture/boar princess.png")
			sprite.scale=Vector2(0.5,0.5)
		elif stat.character_name == "Tea Egg Knight":
			sprite.texture = load("res://picture/tea egg knight  profile.png")
func _physics_process(_delta):
	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1

	velocity = direction.normalized() * speed
	
	move_and_slide()
	
