extends CharacterBody2D


const SPEED = 300.0
var speed = SPEED
const JUMP_VELOCITY = -500.0

var id

@onready var trap_scene = preload("res://assets/trap/trap.tscn")

func _ready() -> void:
	print("player spawned")
	
	if is_multiplayer_authority():
		$Camera2D.make_current()

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Check if there are enemies before calculating distance
	var closest_enemy = get_closest_enemy()
	if closest_enemy:
		var distance_to_enemy = global_position.distance_to(closest_enemy.global_position)
		$HeartBeat.volume_db = clamp(remap(distance_to_enemy, 0, 2000, 20, -20), -INF, 20)
	else:
		$HeartBeat.volume_db = -INF  # Mute if no enemies
	
	$Node2D.rotation = $Node2D.global_position.angle_to_point(get_global_mouse_position())
	
	
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	var direction = input_vector.normalized()
	velocity = direction * speed
	
	update_animation(direction)
	
	move_and_slide()
	rpc("sync_position", global_position)

func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		$AnimationPlayer.stop()
		return
	if direction.x < 0.0:
		if $AnimationPlayer.assigned_animation != "walk_left":
			$AnimationPlayer.play("walk_left")
	elif direction.x > 0.0:
		if $AnimationPlayer.assigned_animation != "walk_right":
			$AnimationPlayer.play("walk_right")
	elif direction.y < 0.0:
		if $AnimationPlayer.assigned_animation != "walk_up":
			$AnimationPlayer.play("walk_up")
	elif direction.y > 0.0:
		if $AnimationPlayer.assigned_animation != "walk_down":
			$AnimationPlayer.play("walk_down")


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

func get_closest_enemy() -> CharacterBody2D:
	var enemies : Array = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		return null
	var closest: CharacterBody2D = null
	var min_distance := INF
	for e in enemies:
		if e is CharacterBody2D:
			var d = global_position.distance_to(e.global_position)
			if d < min_distance:
				min_distance = d
				closest = e
	return closest
