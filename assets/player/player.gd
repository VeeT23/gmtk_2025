extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var id

func _ready() -> void:
	print("player spawned")
	
	if is_multiplayer_authority():
		$Camera2D.make_current()

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		# Apply gravity
		if not is_on_floor():
			velocity.y += get_gravity().y * delta

		# Respawn if too low
		if position.y > 600:
			position = Vector2(629, 339)

		# Jump
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Horizontal movement
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Apply motion and sync position to others
		move_and_slide()
		rpc("sync_position", global_position)
	

@rpc("any_peer")
func sync_position(pos: Vector2):
	if not is_multiplayer_authority():
		global_position = pos
	
	move_and_slide()
