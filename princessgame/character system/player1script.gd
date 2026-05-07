extends CharacterBody2D

@export var speed = 300.0
@onready var sprite = $Sprite2D
var stat = null
func _ready():
	if Global.player1_character != null:
		stat = Global.player1_character
		speed = stat.current_movement
		print("Using character:", stat.character_name)
		print("Speed:", stat.current_movement)

func _physics_process(delta):
	var direction = Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	velocity = direction * speed
	
	if direction.x !=0:
		sprite.flip_h = direction.x<0
	
	move_and_slide()
