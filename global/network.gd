extends Node

@export var port := 7777
@export var max_clients := 8

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

func join_server(ip: String):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	if err != OK:
		push_error("Failed to join server: %s" % err)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connect_failed)
	multiplayer.peer_disconnected.connect(_on_server_disconnected)
	print("Trying to connect to %s:%d" % [ip, port])

func _on_peer_connected(id: int):
	rpc_id(id, "spawn_player", id)

func _on_peer_disconnected(id: int):
	rpc("remove_player", id)

func _on_connected():
	rpc_id(1, "spawn_player", multiplayer.get_unique_id())

func _on_connect_failed():
	print("Connection failed")

func _on_server_disconnected():
	print("Server disconnected")

@rpc("any_peer")
func spawn_player(id: int):
	print("RPC: Spawning player ", id)
	get_tree().call_group("World", "spawn_player", id)

@rpc("any_peer")
func remove_player(id: int):
	print("RPC: Removing player ", id)
	get_tree().call_group("World", "remove_player", id)
