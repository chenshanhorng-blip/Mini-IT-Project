extends CharacterBody2D

@export var speed = 300.0
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	var direction = Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
	velocity = direction * speed
	move_and_slide()
	
	if direction.length() > 0:
		if direction.x > 0:
			animated_sprite.play("right_move")
		elif direction.x < 0:
			animated_sprite.play("left_move")
		elif direction.y > 0:
			animated_sprite.play("down")
		elif direction.y < 0:
			animated_sprite.play("jump") 
	else:
		animated_sprite.play("idle")
