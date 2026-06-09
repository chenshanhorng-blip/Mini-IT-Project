extends CharacterBody2D

@export var speed = 300.0
@onready var animated_sprite = $AnimatedSprite2D
@onready var skill_controller =$skill_adjust
@onready var player_hud = $CanvasLayer/Player

var is_attacking: bool = false
var stat: CharacterStat = null
var facing_direction: Vector2 = Vector2.RIGHT
var is_dead: bool = false


func _ready():
	# Add to "Player" group so boss enemies can find us
	add_to_group("Player")
	add_to_group("player")  # toxicfrog uses lowercase

	if Global.player1_character != null:
		stat = Global.player1_character
		SkillSystem.apply_passive_on_start(stat)
		speed = stat.current_movement

	if stat != null and not stat.health_depleted.is_connected(on_player_dead):
		stat.health_depleted.connect(on_player_dead)

	skill_controller.setup(self, stat)
	player_hud.setup(stat)

	print("Using character:", stat.character_name)
	print("Speed:", stat.current_movement)
	stat.print_stat()

	if stat.character_name == "Boar Princess":
		animated_sprite.play("princess standing")
		animated_sprite.scale = Vector2(0.02, 0.02)
	elif stat.character_name == "Tea Egg Knight":
		animated_sprite.play("knight standing")
		animated_sprite.scale = Vector2(0.5, 0.5)
	else:
		print("No character selected")


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_J:
			receive_damage(50)


# Called by Boss, Mushroom, ToxicFrog, spikes, etc.
func receive_damage(damage: int) -> void:
	if stat == null:
		return
	if is_dead:
		return

	print("Before damage HP:", stat.health)
	CombatSystem.take_damage(stat, damage)
	print("After damage HP:", stat.health)
	stat.print_stat()


# Also expose take_damage() alias so older enemy scripts work without changes
func take_damage(damage: int) -> void:
	receive_damage(damage)


func _process(_delta):
	if stat == null:
		return
	if is_dead:
		return
	skill_controller.handle_input()


func on_player_dead() -> void:
	if is_dead:
		return

	is_dead = true
	speed = 0
	velocity = Vector2.ZERO

	print("Player Dead")
	print("Game Over")

	animated_sprite.visible = false


func _physics_process(_delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		facing_direction = direction
		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0

	velocity = direction * speed
	move_and_slide()
