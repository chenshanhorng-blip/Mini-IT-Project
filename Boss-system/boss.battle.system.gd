extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	RAGE,
	DEAD
}

var health = 1000
var phase = 1
var current_state = State.IDLE

var attack_cooldown = 2.0
var attack_timer = 2.0


func _ready():
	randomize()


func _process(delta):
	if current_state != State.DEAD:
		attack_pattern()


func take_damage(amount):
	health -= amount
	print("Dragon HP:", health)

	if health <= 700 and phase == 1:
		phase_two()

	if health <= 350 and phase == 2:
		phase_three()

	if health <= 0:
		die()


func attack_pattern():
	var move = randi() % 3

	# -------- Phase 1 --------
	if phase == 1:
		if move == 0:
			fireball()
		elif move == 1:
			claw_attack()
		else:
			tail_sweep()

	# -------- Phase 2 --------
	elif phase == 2:
		if move == 0:
			fire_rain()
		elif move == 1:
			summon_minions()
		else:
			charge_attack()

	# -------- Phase 3 --------
	elif phase == 3:
		if move == 0:
			meteor_attack()
		elif move == 1:
			dragon_laser()
		else:
			apocalypse_fire()


# ===== Phase 1 Skills =====

func fireball():
	print("Dragon casts Fireball")


func claw_attack():
	print("Dragon uses Claw Slash")


func tail_sweep():
	print("Dragon uses Tail Sweep")


# ===== Phase 2 Skills =====

func fire_rain():
	print("Dragon summons Fire Rain")


func summon_minions():
	print("Dragon summons baby dragons")


func charge_attack():
	print("Dragon charges player")


# ===== Phase 3 Ultimate Skills =====

func meteor_attack():
	print("Meteor Shower!")


func dragon_laser():
	print("Ancient Dragon Laser!")


func apocalypse_fire():
	print("Apocalypse Flame unleashed!")


# ===== Evolution =====

func phase_two():
	phase = 2
	print("PHASE 2: Winged Dragon Awakens!")


func phase_three():
	phase = 3
	current_state = State.RAGE
	print("PHASE 3: Ancient Dragon Final Form!")


# Weak point bonus damage
func hit_weak_point():
	print("Critical Hit!")
	take_damage(50)


func die():
	current_state = State.DEAD
	print("Dragon Boss Defeated!")
	queue_free()
