extends Node

@export var port := 7777
@export var max_clients := 8

var is_hosting = false
var ip : String;

func create_server():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_clients)
	if err != OK:
		push_error("Failed to create server: %s" % err)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server started on port %d" % port)
	
	# Server spawns its own player after a frame to ensure everything is set up
	await get_tree().process_frame
	spawn_player(1)  # Server always has ID 1

func join_server():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	if err != OK:
		push_error("Failed to join server: %s" % err)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connect_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	print("Trying to connect to %s:%d" % [ip, port])

func _on_peer_connected(id: int):
	print("Peer connected: ", id)
	# Server tells the new client about all existing players
	if multiplayer.is_server():
		# First spawn the new player on all clients (including server)
		rpc("spawn_player", id)
		
		# Then tell the new client about all existing players
		for player_id in get_tree().get_nodes_in_group("players"):
			var existing_id = int(str(player_id.name).split("_")[1])
			if existing_id != id:
				rpc_id(id, "spawn_player", existing_id)

func _on_peer_disconnected(id: int):
	print("Peer disconnected: ", id)
	if multiplayer.is_server():
		rpc("remove_player", id)

func _on_connected():
	print("Connected to server")
	# Client requests to spawn their player
	rpc_id(1, "request_spawn", multiplayer.get_unique_id())

func _on_connect_failed():
	print("Connection failed")

func _on_server_disconnected():
	print("Server disconnected")
	# Clean up all players when server disconnects
	get_tree().call_group("players", "queue_free")

@rpc("any_peer", "call_local", "reliable")
func spawn_player(id: int):
	print("RPC: Spawning player ", id)
	var world = get_tree().get_root().get_node("World")
	if world:
		world.spawn_player(id)

@rpc("any_peer", "call_local", "reliable")
func remove_player(id: int):
	print("RPC: Removing player ", id)
	var world = get_tree().get_root().get_node("World")
	if world:
		world.remove_player(id)

@rpc("any_peer", "reliable")
func request_spawn(id: int):
	# Only server handles spawn requests
	if multiplayer.is_server():
		rpc("spawn_player", id)
