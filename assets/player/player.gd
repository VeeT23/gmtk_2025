extends CharacterBody2D


const SPEED = 300.0
var actual_speed = SPEED
const JUMP_VELOCITY = -500.0

var id

@onready var trap_scene = preload("res://assets/trap/trap.tscn")

func _ready() -> void:
	print("player spawned")
	
	if is_multiplayer_authority():
		$Camera2D.make_current()

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	$Node2D.rotation = $Node2D.global_position.angle_to_point(get_global_mouse_position())
	
	var direction : Vector2 = Vector2(Input.get_axis("left", "right"),Input.get_axis("up", "down"))
	
	if direction:
		if direction.y < 0:
			
			if not $AnimationPlayer.is_playing() or $AnimationPlayer.assigned_animation != "walk_up":
				$AnimationPlayer.play("walk_up")
		elif direction.y > 0:
			if not $AnimationPlayer.is_playing() or $AnimationPlayer.assigned_animation != "walk_down":
				$AnimationPlayer.play("walk_down")
	
	if direction.x:
		velocity.x = direction.x * actual_speed
	else:
		velocity.x = move_toward(velocity.x, 0, actual_speed)
	
	if direction.y:
		velocity.y = direction.y * actual_speed
	else:
		velocity.y = move_toward(velocity.y, 0, actual_speed)
	
	move_and_slide()
	rpc("sync_position", global_position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_debug"):
		get_tree().get_root().get_node("World").reset_scene()

	if event.is_action_pressed("place_trap"):
		var inv_node = get_tree().get_root().get_node("World/CanvasLayer/Inventory")
		var inv = inv_node.inventory if inv_node.has_method("inventory") == false else inv_node.get("inventory")
		
		if "trap" in inv and inv["trap"] > 0:
			inv_node.inventory["trap"] -= 1
			print("Placing trap! Traps left:", inv["trap"])
			spawn_trap()
			get_tree().get_root().get_node("World/CanvasLayer/Inventory").update_item_list()
		else:
			print("No traps in inventory!")

@rpc("any_peer")
func sync_position(pos: Vector2):
	if not is_multiplayer_authority():
		global_position = pos
	
	move_and_slide()

func spawn_trap():
	var trap = trap_scene.instantiate()
	trap.global_position = global_position
	get_tree().get_root().get_node("World").add_child(trap)
