extends CharacterBody2D

const SPEED: float = 200.0

var actual_speed: float = SPEED

var rng = RandomNumberGenerator.new()

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var target_player: CharacterBody2D = null

var starting_pos: Vector2 = Vector2.ZERO

var inactive = false

var roaming = true
var investigating = false
var targeting = false

func _ready() -> void:
	rng.randomize()
	starting_pos = global_position
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_reached.connect(_on_target_reached)
	roam()

func get_closest_player() -> CharacterBody2D:
	if not is_multiplayer_authority():
		return null
	var players : Array = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return null
	var closest: CharacterBody2D = null
	var min_distance := INF
	for p in players:
		if p is CharacterBody2D:
			var d = global_position.distance_to(p.global_position)
			if d < min_distance:
				min_distance = d
				closest = p
	return closest

func makepath() -> void:
	if not targeting: return
	target_player = get_closest_player()
	if target_player:
		nav_agent.target_position = target_player.global_position
		if global_position.distance_to(target_player.global_position) <= 800 and actual_speed:
			actual_speed = SPEED * 2
		else:
			if actual_speed:
				actual_speed = SPEED

func roam():
	print(nav_agent.target_position)
	var max_distance = 5000
	var offset_position = Vector2.RIGHT.rotated(rng.randf_range(-PI, PI)) * rng.randi_range(1000,max_distance)
	var target_position: Vector2 = global_position + offset_position
	await get_tree().create_timer(0.1).timeout
	nav_agent.target_position = Vector2(clamp(target_position.x, -28000, 31000), clamp(target_position.y, -15000, 15000))
	print(nav_agent.target_position)
	print(global_position.distance_to(target_position))

func _on_target_reached() -> void:
	if investigating:
		investigating = false
		roaming = true
	
	print("Target Reached")
	if not roaming: velocity = Vector2.ZERO
	roam()

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if inactive: 
		nav_agent.set_velocity(Vector2.ZERO)
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var desired_velocity: Vector2 = (next_pos - global_position).normalized() * actual_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(desired_velocity)
	else:
		_on_velocity_computed(desired_velocity * _delta)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

	if multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		rpc("sync_position", global_position)

func go_to(pos:Vector2):
	if in_range_of_fire(pos): return
	investigating = true
	nav_agent.target_position = pos

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if not body.is_multiplayer_authority(): return
	if not body.is_in_group("Player"): return
	if inactive: return
	get_tree().get_root().get_node("World/CanvasLayer/JumpScare").jump_scare()
	body.speed = 0
	body.global_position = Vector2.ZERO
	visible = false
	inactive = true
	await get_tree().create_timer(1).timeout
	body.speed = body.SPEED
	global_position = starting_pos
	await get_tree().create_timer(10).timeout
	visible = true
	inactive = false

@rpc("any_peer")
func sync_position(pos: Vector2) -> void:
	if not is_multiplayer_authority():
		global_position = pos

func _on_targeting_update_timeout() -> void:
	makepath()

func _on_target_box_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	targeting = true
	roaming = false
	investigating = false


func _on_target_box_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	targeting = false
	roaming = true
	investigating = false
	roam()

func in_range_of_fire(target_pos : Vector2):
	var camp_fires = get_tree().get_nodes_in_group("Fire")
	if camp_fires.is_empty(): return false
	for fire in camp_fires:
		var distance_to_fire = target_pos.distance_to(fire.global_position)
		print(distance_to_fire)
		if distance_to_fire <= fire.strength:
			print("Protected by campfire")
			return true
	return false
