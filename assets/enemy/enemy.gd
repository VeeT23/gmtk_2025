extends CharacterBody2D

const SPEED: float = 200.0
#halo
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var target_player: CharacterBody2D = null

func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.path_changed.connect(_on_path_changed)
	nav_agent.target_reached.connect(_on_target_reached)
	makepath()

func get_closest_player() -> CharacterBody2D:
	if not is_multiplayer_authority():
		return null
	var nodes: Array = get_tree().get_nodes_in_group("Player")
	if nodes.is_empty():
		return null
	var closest: CharacterBody2D = null
	var min_distance := INF
	for p in nodes:
		if p is CharacterBody2D:
			var d = global_position.distance_to(p.global_position)
			if d < min_distance:
				min_distance = d
				closest = p
	return closest

func makepath() -> void:
	target_player = get_closest_player()
	if target_player:
		nav_agent.target_position = target_player.global_position
		print("New path to:", target_player.global_position)

func _on_timer_timeout() -> void:
	makepath()

func _on_path_changed() -> void:
	print("Path changed:", nav_agent.get_current_navigation_path())

func _on_target_reached() -> void:
	velocity = Vector2.ZERO
	print("Reached target")

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var desired_velocity: Vector2 = (next_pos - global_position).normalized() * SPEED

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(desired_velocity)
	else:
		_on_velocity_computed(desired_velocity * _delta)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

	if multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		rpc("sync_position", global_position)

@rpc("any_peer")
func sync_position(pos: Vector2) -> void:
	if not is_multiplayer_authority():
		global_position = pos
