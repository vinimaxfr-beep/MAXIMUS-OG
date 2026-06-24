extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("interacao") and velocity.y < 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 3

	# Handle jump.
	if Input.is_action_just_pressed("interacao") and is_on_floor():
		$AnimatedSprite2D.play("pular")
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("a_esquerda", "a_direita")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("andar")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	
	
	move_and_slide()
