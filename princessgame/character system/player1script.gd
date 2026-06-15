extends CharacterBody2D
# call the ui set the character stat as 300 and call the node 
@export var speed = 300.0
@onready var animated_sprite = $AnimatedSprite2D
@onready var skill_controller = $skill_adjust
@onready var player_hud = $CanvasLayer/Player

var is_attacking: bool = false
var stat: CharacterStat = null
var facing_direction: Vector2 = Vector2.RIGHT
var is_dead: bool = false

func _ready():
	if Global.player1_character != null:
		stat = Global.player1_character

		SkillSystem.apply_passive_on_start(stat)
		speed = stat.current_movement

	if not stat.health_depleted.is_connected(on_player_dead):
		stat.health_depleted.connect(on_player_dead)

	skill_controller.setup(self, stat)
	player_hud.setup(stat)

	print("Using character:", stat.character_name)
	print("Speed:", stat.current_movement)
	stat.print_stat()

	if stat.character_name == "Boar Princess":
		animated_sprite.play("princess standing")
		animated_sprite.scale = Vector2(0.2, 0.2)

	elif stat.character_name == "Tea Egg Knight":
		animated_sprite.play("knight standing")
		animated_sprite.scale = Vector2(0.5, 0.5)

	else:
		print("No character selected")
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_J:
			receive_damage(50)


#call the ui set the character stat as 300 and call the node 
@export var speed = 300.0
@onready var animated_sprite = $AnimatedSprite2D
var is_attacking: bool = false

var stat: CharacterStat = null
#function for the basic attack animation and basic attack attack 
# function for the basic attack animation and basic attack attack 
func basic_attack_animation() -> void:
	if stat == null:
		return

	if is_attacking:
		return

	is_attacking = true
	
	print("Basic Attack pressed")
	CombatSystem.basic_attack_1(stat)

	if stat.character_name == "Boar Princess":
		animated_sprite.play("princess basic attack ")

	elif stat.character_name == "Tea Egg Knight":
		animated_sprite.play("knight basic attack")

	await animated_sprite.animation_finished

	if stat.character_name == "Boar Princess":
		animated_sprite.play("princess standing ")

	elif stat.character_name == "Tea Egg Knight":
		animated_sprite.play("knight standing")

	is_attacking = false

func receive_damage(damage:int) -> void:
	if stat == null:
		return

	if is_dead:
		return
	print("Before damage HP:", stat.health)

	CombatSystem.take_damage(stat, damage)
	
	print("After damage HP:", stat.health)

	stat.print_stat()

func _process(_delta):
	if stat == null:
		return

	if is_dead:
		return

	skill_controller.handle_input()
#the death and game over system 
func on_player_dead() -> void:
	if is_dead:
		return

	is_dead = true
	speed = 0
	velocity = Vector2.ZERO

	print("Player Dead")
	print("Game Over")

	animated_sprite.visible = false
	

# the function to let character moving 
func _physics_process(_delta):
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	
	CombatSystem.take_damage(stat, damage)
	stat.print_stat()


func _ready():
	if Global.player1_character != null:
		stat = Global.player1_character
	
		# Passive skill only
		SkillSystem.apply_passive_on_start(stat)

		speed = stat.current_movement

		print("Using character:", stat.character_name)
		print("Speed:", stat.current_movement)
		stat.print_stat()

	if stat.character_name == "Boar Princess":
		animated_sprite.play("princess standing ")
		animated_sprite.scale = Vector2(0.2, 0.2)

	elif stat.character_name == "Tea Egg Knight":
		animated_sprite.play("knight standing")


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_J:
			receive_damage(10)


func _process(_delta):
	if stat == null:
		return
	if Input.is_action_just_pressed("basic attack"):
		basic_attack_animation()


	if Input.is_action_just_pressed("skill1"):
		print("Skill 1 pressed")
		SkillSystem.use_skill_1(stat)
		stat.print_stat()

	if Input.is_action_just_pressed("skill2"):
		print("Skill 2 pressed")
		SkillSystem.use_skill_2(stat)
		speed = stat.current_movement
		stat.print_stat()

	if Input.is_action_just_pressed("ultimate"):
		print("Ultimate pressed")
		use_ultimate_action()

#the function for princess when use the ultimate the princess will enhance 6s 
func use_ultimate_action() -> void:
	if stat == null:
		return

	if stat.character_name == "Boar Princess":
		if stat.ultimate_active:
			print("Princess Ultimate is already active")
			return

		SkillSystem.start_princess_ultimate(stat)

	# update player movement speed
		speed = stat.current_movement
		print("Princess ultimate speed:", speed)

		await get_tree().create_timer(6.0).timeout

		SkillSystem.end_princess_ultimate(stat)

		# restore player movement speed
		speed = stat.current_movement
		print("Princess normal speed:", speed)

	else:
		SkillSystem.use_ultimate(stat)
		speed = stat.current_movement
# the function to let character moving 
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

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		facing_direction = direction

		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0

	velocity = direction * speed
	velocity = direction.normalized() * speed

	
	move_and_slide()
