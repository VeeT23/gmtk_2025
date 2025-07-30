extends CharacterBody2D


const SPEED = 200.0

var target_player : CharacterBody2D = null

func get_closest_player() -> CharacterBody2D:
	if not is_multiplayer_authority(): return
	var player_nodes = get_tree().get_nodes_in_group("Player")
	if player_nodes.is_empty():
		return null
	
	var closest_player: CharacterBody2D = null
	var min_distance := INF
	for player in player_nodes:
		if not player is CharacterBody2D:
			continue
		var dist = position.distance_to(player.position)
		if dist < min_distance:
			min_distance = dist
			closest_player = player
	
	return closest_player

func _physics_process(_delta: float) -> void:
	target_player = get_closest_player()
	if not target_player: return
	
	var direction = (target_player.global_position - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()
	
	rpc("sync_position", global_position)


@rpc("any_peer")
func sync_position(pos: Vector2):
	if not is_multiplayer_authority():
		global_position = pos
	
	move_and_slide()
