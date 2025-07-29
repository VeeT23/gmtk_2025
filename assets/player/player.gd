extends CharacterBody2D

@export var speed := 200.0
@onready var animation_player = $AnimationPlayer  # Assuming an AnimationPlayer node for movement animations

func _ready() -> void:
	add_to_group("players")
	if not is_multiplayer_authority():
		set_process(false)  # Disable processing for non-authoritative players

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Handle input for movement
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * speed
		# Simple animation control (adjust based on your sprite setup)
		if animation_player:
			animation_player.play("walk")
	else:
		velocity = Vector2.ZERO
		if animation_player:
			animation_player.play("idle")
	
	move_and_slide()

# Optional: Sync position across peers (if needed for smoother interpolation)
@rpc("authority", "call_local", "reliable")
func update_position(pos: Vector2) -> void:
	if not is_multiplayer_authority():
		global_position = pos

func _process(_delta: float) -> void:
	if is_multiplayer_authority() and multiplayer.is_server():
		# Periodically sync position for clients (e.g., every 0.1 seconds)
		rpc("update_position", global_position)
