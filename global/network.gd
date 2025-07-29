extends Node

@export var port := 7777
@export var max_clients := 8
@export var ip := "localhost"
var is_hosting := false

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	if OS.has_feature("server"):
		is_hosting = true
		start_server()
	else:
		await get_tree().create_timer(0.1).timeout
		connect_to_server()

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_clients)
	if error != OK:
		push_error("Failed to start server: %s" % error_string(error))
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)
	spawn_player(multiplayer.get_unique_id())

func connect_to_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		push_error("Failed to connect to server: %s" % error_string(error))
		return
	multiplayer.multiplayer_peer = peer
	print("Trying to connect to %s:%d" % [ip, port])
	
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_ok() -> void:
	print("Connected to server with ID: %d" % multiplayer.get_unique_id())
	rpc_id(1, "register_client", multiplayer.get_unique_id())

func _on_connection_failed() -> void:
	print("Connection to server failed")

func _on_server_disconnected() -> void:
	print("Disconnected from server")
	multiplayer.multiplayer_peer = null
	for id in get_tree().get_nodes_in_group("players"):
		id.queue_free()

func _on_peer_connected(id: int) -> void:
	print("Peer connected: %d" % id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: %d" % id)
	rpc("unregister_player", id)

@rpc("any_peer", "call_local", "reliable")
func register_client(id: int) -> void:
	if multiplayer.is_server():
		print("Client registered: %d" % id)
		spawn_player(id)
		for peer_id in get_tree().get_nodes_in_group("players").map(func(node): return node.name.split("_")[1].to_int()):
			if peer_id != id:
				rpc_id(id, "spawn_player", peer_id)

@rpc("any_peer", "call_local", "reliable")
func unregister_player(id: int) -> void:
	var world = get_node_or_null("/root/World")
	if world and world.has_node("Player_%d" % id):
		world.get_node("Player_%d" % id).queue_free()

@rpc("any_peer", "call_local", "reliable")
func spawn_player(id: int) -> void:
	var world = get_node_or_null("/root/World")
	if world and not world.has_node("Player_%d" % id):
		var player = preload("res://assets/player/player.tscn").instantiate()
		player.name = "Player_%d" % id
		player.set_multiplayer_authority(id)
		world.add_child(player)
		print("Spawned player %s with authority: %s, peer_id: %d" % [player.name, player.is_multiplayer_authority(), multiplayer.get_unique_id()])
