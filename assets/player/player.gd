extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var id

func _ready() -> void:
	print("player spawned")
	
	if is_multiplayer_authority():
		$Camera2D.make_current()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	
	var direction : Vector2 = Vector2(Input.get_axis("left", "right"),Input.get_axis("up", "down") )
	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction.y:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# Apply motion and sync position to others
	move_and_slide()
	rpc("sync_position", global_position)


@rpc("any_peer")
func sync_position(pos: Vector2):
	if not is_multiplayer_authority():
		global_position = pos
	
	move_and_slide()
