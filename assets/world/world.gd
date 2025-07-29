extends Node2D

var player_scene: PackedScene = preload("res://assets/player/player.tscn")
var players := {}

func _ready() -> void:
	name = "World"
	print("World ready on %d" % multiplayer.get_unique_id())
	if multiplayer.is_server():
		spawn_player(multiplayer.get_unique_id())
	else:
		await get_tree().create_timer(0.2).timeout  # Wait for connection
		var network = get_node_or_null("/root/Network")
		if network:
			network.connect_to_server()

func spawn_player(id: int) -> void:
	if has_node("Player_%d" % id):
		print("Player %d already spawned, skipping." % id)
		return
	var player = player_scene.instantiate()
	if not player:
		push_error("Failed to instantiate player scene!")
		return
	player.name = "Player_%d" % id
	player.set_multiplayer_authority(id)
	add_child(player)
	players[id] = player
	print("Player spawned: %s, authority: %s, peer_id: %d" % [player.name, player.is_multiplayer_authority(), multiplayer.get_unique_id()])

func _process(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	for player in get_tree().get_nodes_in_group("players"):
		if player.is_multiplayer_authority():
			player.move_and_slide()  # Example movement, adjust as needed
