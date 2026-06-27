extends Area2D

@export var speed: float = 450.0
@export var damage: int = 20 # Damage dealt to player

# Default flying direction (will be updated by the boss script)
var direction: Vector2 = Vector2.RIGHT 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# ---------------------------------------------------------
	# 🛠️ RANGE FIX 1: Auto-destroy after 2.0 seconds (Max Range)
	# This ensures the fireball won't fly forever. You can change 2.0 to 3.0 for longer range.
	# ---------------------------------------------------------
	get_tree().create_timer(2.0).timeout.connect(queue_free)

	# Automatically connect collision signal
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		
	# Play fireball animation on spawn
	if sprite:
		sprite.play("Fireball") 

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

## Core Function: Receives direction from boss and flips the sprite horizontally
func set_fireball_direction(dir: Vector2) -> void:
	direction = dir
	if sprite:
		if dir.x < 0:
			sprite.flip_h = true  # Flying left: flip sprite horizontally
		else:
			sprite.flip_h = false # Flying right: keep original sprite direction

func _on_body_entered(body: Node2D) -> void:
	print("Fireball touched something! Node Name: ", body.name, " | Class: ", body.get_class())

	# 1. Ignore the Enemy/Boss or anything named Demo
	if body.name.to_lower().contains("enemy") or body.name.to_lower().contains("demo"):
		return 

	# 🛠️ NEW FIX: Ignore the Ground layer if the fireball is spawning too close to it
	if body.name == "Ground":
		return # 📝 强行无视这个叫 Ground 的节点，让火球穿过去，绝不自杀！

	# 2. Check if the collided body belongs to the "player" group
	if body.is_in_group("player") or body.name.to_lower() == "player":
		print("🔥 SUCCESS: Fireball hit Player!")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free() 
		return

	# 3. STRICT WALL CHECK (Only other solid walls will destroy it)
	if body is TileMap or body.is_class("TileMapLayer"):
		print("🧱 Fireball hit a solid wall.")
		queue_free()
