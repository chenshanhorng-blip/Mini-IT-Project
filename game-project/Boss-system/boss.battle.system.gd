
extends CharacterBody2D

# =====================================================
# BOSS BATTLE SYSTEM
# Combined with Princess Game's CharacterStat system
# Boss now deals damage through CombatSystem and
# reads player stats from Global.player1_character
# =====================================================

enum State { IDLE, RAGE, DEAD }

var max_health = 1000
var health = 1000
var phase = 1
var current_state = State.IDLE

var attack_cooldown = 2.0
var attack_timer = 0.0

@export var fireball_scene: PackedScene

# Reference to player node (CharacterBody2D in scene)
var player_node = null
# Reference to player's stat (CharacterStat resource from Global)
var player_stat: CharacterStat = null


func _ready():
	randomize()

	# --- Connect to princess game player ---
	# Try to find player node by group first, then by name
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_node = players[0]
	else:
		player_node = get_parent().get_node_or_null("Player")

	# Get the player's CharacterStat from Global autoload
	if Global.player1_character != null:
		player_stat = Global.player1_character
		print("Boss connected to player stat: ", player_stat.character_name)
	else:
		print("Warning: No player1_character found in Global")

	$BossHealthBar.max_value = max_health
	$BossHealthBar.value = health


func _process(delta):
	if current_state == State.DEAD:
		return

	attack_timer -= delta

	if attack_timer <= 0:
		await attack_pattern()
		attack_timer = attack_cooldown


# =====================================================
# DAMAGE — now routes through CombatSystem
# so shield, passives, and death signals all work
# =====================================================
func take_damage(amount):
	health -= amount
	$BossHealthBar.value = health

	if randi() % 3 == 0:
		await speak("You dare hit me?! How dare you!!!! I want to kill you!")

	if health <= 700 and phase == 1:
		await phase_two()

	if health <= 350 and phase == 2:
		await phase_three()

	if health <= 0:
		await die()


# Deal damage TO the player using CombatSystem
func deal_damage_to_player(amount: int):
	if player_stat == null:
		# Fallback: call take_damage directly if player has the method
		if player_node != null and player_node.has_method("receive_damage"):
			player_node.receive_damage(amount)
		return

	# Use CombatSystem so shield, passives, and death signals all fire correctly
	CombatSystem.take_damage(player_stat, amount)
	print("Boss dealt ", amount, " damage to ", player_stat.character_name)


# =====================================================
# ATTACK PATTERNS
# =====================================================
func attack_pattern():
	var move = randi() % 4

	if phase == 1:
		match move:
			0: await fireball()
			1: await ground_smash()
			2: await fireball()
			3: await ground_smash()

	elif phase == 2:
		match move:
			0: await fire_breath()
			1: await fireball()
			2: await charge_attack()
			3: await ground_smash()

	elif phase == 3:
		match move:
			0: await fire_breath()
			1: await meteor_attack()
			2: await apocalypse_fire()
			3: await fire_breath()


func fireball():
	await speak("Burn!")
	spawn_fire(0)


func fire_breath():
	await speak("BURN EVERYTHING!!!")
	for i in range(8):
		spawn_fire(-0.3)
		spawn_fire(0)
		spawn_fire(0.3)
		await get_tree().create_timer(0.2).timeout


func spawn_fire(angle_offset):
	if fireball_scene == null:
		return
	var fb = fireball_scene.instantiate()
	get_parent().add_child(fb)
	fb.position = $FireballSpawn.global_position

	if player_node != null:
		var dir = (player_node.position - fb.position).normalized()
		dir = dir.rotated(angle_offset)
		fb.direction = dir

	fb.speed = 400 + (phase * 100)


func ground_smash():
	await speak("CRUSH!!!")
	await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(0.3).timeout

	if player_node != null:
		if player_node.position.distance_to(position) < 120:
			# Damage scales with phase
			var smash_damage = 20 + (phase * 10)
			deal_damage_to_player(smash_damage)


func charge_attack():
	await speak("You cannot escape!")
	# Deal moderate damage during charge
	deal_damage_to_player(15 * phase)


func meteor_attack():
	await speak("Meteor fall!")
	deal_damage_to_player(25 * phase)


func apocalypse_fire():
	await speak("End of all!!!")
	deal_damage_to_player(40)


# =====================================================
# DIALOGUE
# =====================================================
func speak(text):
	$BossDialogue.text = ""
	$BossDialogue.visible = true

	for c in text:
		$BossDialogue.text += c
		await get_tree().create_timer(0.03).timeout

	await get_tree().create_timer(1.2).timeout
	$BossDialogue.visible = false


# =====================================================
# PHASE TRANSITIONS
# =====================================================
func phase_two():
	phase = 2
	attack_cooldown = 1.5
	await speak("You dare challenge me?")


func phase_three():
	phase = 3
	current_state = State.RAGE
	attack_cooldown = 0.8
	await speak("Feel my TRUE POWER!!!")


func die():
	current_state = State.DEAD
	await speak("Impossible...")
	queue_free()
