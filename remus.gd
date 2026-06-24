extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
var pos_direita = Vector2(92, -20)
var pos_esquerda = Vector2(-88, -20)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("interacao") and velocity.y < 0:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 3

	# Handle jump.
	if Input.is_action_just_pressed("interacao") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		
func atacar():
	if Input.is_action_just_pressed("ataque"):
		$AttackSprite.visible = true
	if $AnimatedSprite2D.flip_h:
		$AttackSprite.position = Vector2(-88, -20)
	else:
		$AttackSprite.position = Vector2(-91, -20) # ou sua posição original
		
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("a_esquerda", "a_direita")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	animacao()
	move_and_slide()


func animacao():
	if velocity.y < 0:
		$AnimatedSprite2D.play("pular")
	elif velocity.x != 0:
		$AnimatedSprite2D.play("andar")
	else:
		$AnimatedSprite2D.play("idle")

	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	
func animacao_ataque():
	if $AttackSprite.flip_h:
		$AttackSprite.position = pos_esquerda
	else:
		$AttackSprite.position = pos_direita
