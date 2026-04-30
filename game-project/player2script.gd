extends CharacterBody2D

@export var speed = 300.0

@onready var sprite = $Sprite2D

func _physics_process(delta):
	var direction = Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
	velocity = direction * speed
	
	if direction.x !=0:
		sprite.flip_h = direction.x<0
	
	move_and_slide()
