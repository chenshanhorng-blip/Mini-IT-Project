extends Node
class_name skill_adjust
#the player's data
var player = null
var player_id: int = 1
var stat: CharacterStat = null
var is_attacking: bool = false

@onready var animated_sprite = $"../AnimatedSprite2D"

@onready var knight_skill2_effect = $"../skilleffect/knightskill2effect"
@onready var knight_ultimate_effect = $"../skilleffect/knightultimateeffect"
@onready var princess_basic_attack_effect = $"../skilleffect/basicattackofprincess"
@onready var princess_skill1_effect = $"../skilleffect/skill1effectofprincess"

@onready var knight_skill2_start = $"../skilleffect/knightskill2effect_start"
@onready var knight_ultimate_start = $"../skilleffect/knightultimateeffect_start"
@onready var princess_basic_start = $"../skilleffect/basicattackofprincess_start"
@onready var princess_skill1_start = $"../skilleffect/skill1effectofprincess_start"

@onready var skill_damage_area = $skill_area
@onready var skill_damage_shape = $skill_area/CollisionShape2D

@onready var princess_basic_sound = $"../PrincessBasicAttack"
@onready var princess_skill1_sound = $"../PrincessSkill1"
@onready var princess_skill2_sound = $"../PrincessSkill2"
@onready var princess_ultimate_sound = $"../PrincessUltimate"

@onready var knight_basic_sound = $"../attackknight"
@onready var knight_skill1_sound = $"../KnightSkill1"
@onready var knight_skill2_sound = $"../KnightSkill2"
@onready var knight_ultimate_sound = $"../KnightUltimate"

var current_skill_damage: int = 0
var current_skill_name: String = ""
var damaged_enemy_list: Array = []
#set up
func setup(new_player, new_stat: CharacterStat,new_player_id: int = 1) -> void:
	player = new_player
	stat = new_stat
	player_id = new_player_id
	hide_all_effects()

	skill_damage_area.monitoring = false
	skill_damage_shape.disabled = true

	# Detect enemies on ALL layers — dragon is on layer 2, regular enemies on layer 1
	skill_damage_area.collision_mask = 0b1111

	# The CircleShape2D on skill_area has no radius set in the scene,
	# which makes it default to Godot's tiny built-in radius (10px).
	# Force a usable radius here so basic attack / skills can actually
	# reach and hit enemies standing in front of the player.
	if skill_damage_shape.shape is CircleShape2D:
		var circle_shape: CircleShape2D = skill_damage_shape.shape
		if circle_shape.radius < 30.0:
			circle_shape.radius = 40.0
			print("skill_adjust: CircleShape2D radius was too small, set to 40.0")
	
	var signal_callable = Callable(self, "_on_skill_damage_area_body_entered")
	if not skill_damage_area.body_entered.is_connected(signal_callable):
		skill_damage_area.body_entered.connect(signal_callable)
	#新加的
	var area_callable = Callable(self, "_on_skill_area_entered")
	if not skill_damage_area.area_entered.is_connected(area_callable):
		skill_damage_area.area_entered.connect(area_callable)
	
# Hide Effects
func hide_all_effects() -> void:
	knight_skill2_effect.visible = false
	knight_ultimate_effect.visible = false
	princess_basic_attack_effect.visible = false
	princess_skill1_effect.visible = false

# play effect at the marker position
func play_effect_at_marker(effect: AnimatedSprite2D, marker: Marker2D, duration: float = 0.5) -> void:
	effect.global_position = marker.global_position
	effect.visible = true
	effect.frame = 0
	effect.play()

	await get_tree().create_timer(duration).timeout

	effect.visible = false

# play effect from marker position and fly forward
func play_flying_effect_from_marker(effect: AnimatedSprite2D, marker: Marker2D, fly_distance: float, duration: float = 0.4) -> void:
	var start_position = marker.global_position
	# Use player.facing_direction instead of flip_h (flip_h is never set in this game)
	var direction_sign = 1
	if player != null and player.get("facing_direction") != null:
		if player.facing_direction.x < 0:
			direction_sign = -1

	effect.global_position = start_position
	effect.visible = true
	effect.frame = 0
	effect.flip_h = direction_sign < 0
	effect.play()

	var tween = create_tween()
	tween.tween_property(
		effect,
		"global_position",
		start_position + Vector2(fly_distance * direction_sign, 0),
		duration
	)

	await get_tree().create_timer(duration).timeout

	effect.visible = false
	
# function for the basic attack animation and basic attack attack 
func basic_attack_animation() -> void:
	if stat == null:
		return

	if is_attacking:
		return

	is_attacking = true
	
	print("Basic Attack pressed")
	CombatSystem.basic_attack_1(stat)
	if stat.character_name == "Tea Egg Knight":
		knight_basic_sound.play()
		animated_sprite.play("knight basic attack")
		# Knight basic attack — damage area in front of the knight
		activate_skill_damage_area(
			princess_basic_start,
			stat.current_attack,
			0.3,
			Vector2(1.5, 1),
			"knight_basic"
		)

	elif stat.character_name == "Boar Princess":
		princess_basic_sound.play()
		animated_sprite.play("princess basic attack")
		_fire_travelling_projectile(
			princess_basic_attack_effect,
			princess_basic_start,
			600.0,
			0.5,
			stat.current_attack,
			"princess_basic"
		)
 
	await animated_sprite.animation_finished
	is_attacking = false
		# Princess basic attack — damage area where the effect flies through

func _fire_travelling_projectile(
		effect: AnimatedSprite2D,
		start_marker: Marker2D,
		distance: float,
		duration: float,
		damage: int,
		_skill_name: String
	) -> void:
 
	# Use player.facing_direction to determine projectile direction
	# because this game uses separate left/right animations, not flip_h
	var dir_sign = 1  # default right
	if player != null and player.get("facing_direction") != null:
		dir_sign = int(sign(player.facing_direction.x)) if player.facing_direction.x != 0 else 1
	var start_pos = start_marker.global_position
	var end_pos = start_pos + Vector2(distance * dir_sign, 0)
 
	# Show and move the visual effect
	effect.global_position = start_pos
	effect.visible = true
	effect.flip_h = dir_sign < 0  # flip effect sprite when going left
	effect.frame = 0
	effect.play()
 
	# Track who was already hit (so we don't hit the same enemy twice)
	var already_hit: Array = []
 
	var tween = create_tween()
	tween.tween_property(effect, "global_position", end_pos, duration)
 
	# Check for hits every frame while the projectile travels
	var elapsed = 0.0
	var step = 0.05  # check every 50ms
	while elapsed < duration:
		await get_tree().create_timer(step).timeout
		elapsed += step
 
		# Get all enemies AND bosses, combine into one target list
		var targets: Array = get_tree().get_nodes_in_group("enemy")
		for boss in get_tree().get_nodes_in_group("Boss"):
			if boss not in targets:
				targets.append(boss)

		for enemy in targets:
			if enemy in already_hit:
				continue
			if not is_instance_valid(enemy):
				continue

			var dist = effect.global_position.distance_to(enemy.global_position)

			# 调试用：把每次算出来的距离打出来，方便确认判定范围够不够
			print("Checking hit vs ", enemy.name, " dist=", dist)

			# Hit radius: small for normal enemies (precise), large for big bosses
			var hit_radius = 60.0
			if enemy.is_in_group("Boss"):
				hit_radius = 200.0

			if dist < hit_radius:
				already_hit.append(enemy)
				if enemy.has_method("receive_damage"):
					enemy.receive_damage(damage)
				elif enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				print("Princess projectile hit:", enemy.name, " damage:", damage)
 
	effect.visible = false
	
#skill damage area 
func activate_skill_damage_area(marker: Marker2D, damage: int, duration: float, area_scale: Vector2 = Vector2(1, 1), skill_name: String = "") -> void:
	current_skill_damage = damage
	current_skill_name = skill_name
	damaged_enemy_list.clear()

	skill_damage_area.global_position = marker.global_position
	skill_damage_area.scale = area_scale

	skill_damage_shape.disabled = false
	skill_damage_area.monitoring = true

	print("Damage area active:", skill_name, " Damage:", damage, " | world position:", skill_damage_area.global_position, " | scale:", skill_damage_area.scale)

	# body_entered only fires when a body ENTERS the area.
	# If the enemy is already overlapping (standing inside a large boss),
	# the signal never fires — check existing overlaps immediately.
	await get_tree().physics_frame
	for body in skill_damage_area.get_overlapping_bodies():
		_on_skill_damage_area_body_entered(body)

	await get_tree().create_timer(duration).timeout

	skill_damage_area.monitoring = false
	skill_damage_shape.disabled = true

	current_skill_damage = 0
	current_skill_name = ""
	damaged_enemy_list.clear()

	print("Damage area closed")
#the enemy touch skill and cause damage system 
func _on_skill_damage_area_body_entered(body) -> void:
	# Skip the player themselves — skill should never damage own character
	if body == player:
		return
	if body.is_in_group("player") or body.is_in_group("Player"):
		return

	if body in damaged_enemy_list:
		return

	damaged_enemy_list.append(body)

	if body.has_method("receive_damage"):
		body.receive_damage(current_skill_damage)
		print("Enemy touched skill area. Damage:", current_skill_damage)

		if current_skill_name == "tea_skill2":
			stat.health += 10
			stat.health = clamp(stat.health, 0, stat.current_max_health)
			print("Tea Egg Knight Skill 2 hit enemy: recovered 10 HP")
			stat.print_stat()
	else:
		print("Enemy touched area but has no receive_damage()")
		
		#新加的
func _on_skill_area_entered(area) -> void:

	if !area.is_in_group("boss_projectile"):
		return

	if current_skill_name == "boar_skill2" or current_skill_name == "tea_skill1":
		print("Projectile Destroyed!")
		area.queue_free()

func use_skill_1_action() -> void:
	if stat == null:
		return

	if is_attacking:
		return

	is_attacking = true

	print("Skill 1 pressed")

	if stat.character_name == "Boar Princess":
		princess_skill1_sound.play()
		animated_sprite.play("skill 1 of boar princess")
		play_flying_effect_from_marker(
			princess_skill1_effect,
			princess_skill1_start,
			600,
			0.3
			)
		
		activate_skill_damage_area(
		princess_skill1_start,
		stat.current_attack + 10,
		0.4,
		Vector2(2, 1),
		"boar_skill1"
		)
	elif stat.character_name == "Tea Egg Knight":

		knight_skill1_sound.play()

		animated_sprite.play("skill 1 tea egg knight")
		#新加的
		activate_skill_damage_area(
			knight_skill2_start,   # 或者改成你 Skill1 对应的 Marker
			0,
			1.0,
			Vector2(2, 2),
			"tea_skill1"
		)

	SkillSystem.use_skill_1(stat)
	player.speed = stat.current_movement
	stat.print_stat()

	await animated_sprite.animation_finished

	is_attacking = false


func use_skill_2_action() -> void:
	if stat == null:
		return

	if is_attacking:
		return

	is_attacking = true

	print("Skill 2 pressed")

	if stat.character_name == "Boar Princess":
		princess_skill2_sound.play()
		animated_sprite.play("princess skill 2")
		#新加的
		activate_skill_damage_area(
		princess_skill1_start,
		0,
		1.0,
		Vector2(2,2),
		"boar_skill2"
	)

	elif stat.character_name == "Tea Egg Knight":
		knight_skill2_sound.play()
		animated_sprite.play("skill 2 tea egg knight")
		play_flying_effect_from_marker(
			knight_skill2_effect,
			knight_skill2_start,
			400,
			0.6
		)
		activate_skill_damage_area(
		knight_skill2_start,
		stat.current_attack + 10,
		0.6,
		Vector2(2, 1),
		"tea_skill2"
		)

	SkillSystem.use_skill_2(stat)
	player.speed = stat.current_movement
	stat.print_stat()

	await animated_sprite.animation_finished

	is_attacking = false

# the function for princess when use the ultimate the princess will enhance 6s 
func use_ultimate_action() -> void:
	if stat == null:
		return

	if stat.character_name == "Boar Princess":
		if stat.ultimate_active:
			print("Princess Ultimate is already active")
			return

		print("Ultimate pressed")

		# Start ultimate buff
		SkillSystem.start_princess_ultimate(stat)

		# Make princess bigger
		princess_ultimate_sound.play()
		animated_sprite.scale = Vector2(0.08, 0.08)

		# Update movement speed
		player.speed = stat.current_movement
		print("Princess ultimate speed:", player.speed)

		# Keep standing animation, no ultimate animation

		# Buff lasts 6 seconds
		await get_tree().create_timer(6.0).timeout

		# End ultimate buff
		SkillSystem.end_princess_ultimate(stat)

		# Restore normal size
		animated_sprite.scale = Vector2(0.05069446, 0.05385417)

		# Restore movement speed
		player.speed = stat.current_movement
		print("Princess normal speed:", player.speed)
		#the part for the tea egg knight
	elif stat.character_name == "Tea Egg Knight":
		if is_attacking:
			return
			
		is_attacking = true
		print("Ultimate pressed")
		knight_ultimate_sound.play()
		animated_sprite.play("ultimate of tea egg knight ")
		play_effect_at_marker(
			knight_ultimate_effect,
			knight_ultimate_start,
			0.8
			)
		activate_skill_damage_area(
		knight_ultimate_start,
		stat.current_attack + 30,
		0.8,
		Vector2(2.5, 2),
		"tea_ultimate"
		)

		SkillSystem.use_ultimate(stat)
		player.speed = stat.current_movement
		stat.print_stat()
	
		await animated_sprite.animation_finished
		is_attacking = false

func handle_input() -> void:
	if stat == null:
		return
 
	# Pick the correct input action names based on which player this is
	var action_basic_attack = "basic attack" if player_id == 1 else "p2_basic_attack"
	var action_skill1       = "skill1"        if player_id == 1 else "p2_skill1"
	var action_skill2       = "skill2"        if player_id == 1 else "p2_skill2"
	var action_ultimate     = "ultimate"       if player_id == 1 else "p2_ultimate"
 
	if Input.is_action_just_pressed(action_basic_attack):
		basic_attack_animation()
 
	if Input.is_action_just_pressed(action_skill1):
		if is_attacking:
			return
 
		if skill_cooldown.can_use_skill(stat, "skill1"):
			skill_cooldown.start_cooldown(stat, "skill1")
			use_skill_1_action()
		else:
			print("Skill 1 cooldown:", ceil(skill_cooldown.get_remaining_time(stat, "skill1")))
 
	if Input.is_action_just_pressed(action_skill2):
		if is_attacking:
			return
 
		if skill_cooldown.can_use_skill(stat, "skill2"):
			skill_cooldown.start_cooldown(stat, "skill2")
			use_skill_2_action()
		else:
			print("Skill 2 cooldown:", ceil(skill_cooldown.get_remaining_time(stat, "skill2")))
 
	if Input.is_action_just_pressed(action_ultimate):
		# Princess ultimate is buff, do not block basic attack / skill
		if stat.character_name == "Boar Princess":
			if skill_cooldown.can_use_skill(stat, "ultimate"):
				skill_cooldown.start_cooldown(stat, "ultimate")
				use_ultimate_action()
			else:
				print("Ultimate cooldown:", ceil(skill_cooldown.get_remaining_time(stat, "ultimate")))
 
		# Tea Egg Knight ultimate has animation, so it can be blocked by is_attacking
		elif stat.character_name == "Tea Egg Knight":
			if is_attacking:
				return
 
			if skill_cooldown.can_use_skill(stat, "ultimate"):
				skill_cooldown.start_cooldown(stat, "ultimate")
				use_ultimate_action()
			else:
				print("Ultimate cooldown:", ceil(skill_cooldown.get_remaining_time(stat, "ultimate")))
