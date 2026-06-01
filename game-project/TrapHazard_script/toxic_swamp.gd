extends Area2D

@export var damage_amount: int = 10         # Damage per tick
@export var speed_reduction_pct: float = 0.5 # Reduces speed to 50%

@onready var damage_timer: Timer = $Timer

# CHANGED: Changed 'nil' to 'null' here
var player_node: Node2D = null

func _ready() -> void:
	# Damage interval setup (triggers damage every 0.5 seconds)
	damage_timer.wait_time = 0.5 
	damage_timer.one_shot = false
	damage_timer.autostart = false
	
	# Connect Area2D built-in signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	damage_timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	# Verify entering object belongs to the 'player' group
	if body.is_in_group("player"):
		player_node = body
		
		# Apply instant effects upon stepping into the swamp
		player_node.apply_speed_modifier(speed_reduction_pct)
		player_node.take_damage(damage_amount)
		
		# Start continuous ticking damage
		damage_timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body == player_node:
		# Restore normal movement states and stop timer safely
		player_node.apply_speed_modifier(1.0)
		# CHANGED: Changed 'nil' to 'null' here too
		player_node = null
		damage_timer.stop()

func _on_timer_timeout() -> void:
	# Safely double-check if player instance still exists before applying tick damage
	if is_instance_valid(player_node):
		player_node.take_damage(damage_amount)
