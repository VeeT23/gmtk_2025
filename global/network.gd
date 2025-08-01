extends Node

@export var port := 7777
@export var max_clients := 8

var is_hosting = false
var ip : String
var game_started = false
var connected_players = {}  # Store player info {id: name}
var server_seed = 0

func create_server():
	server_seed = Time.get_ticks_usec() % 1000000000
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_clients)
	if err != OK:
		push_error("Failed to create server: %s" % err)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server started on port %d" % port)
	
	# Add server to connected players
	connected_players[1] = "Host"
	
	# Server loads lobby
	get_tree().change_scene_to_file("res://ui/lobby.tscn")

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
	# Reject connection if game already started
	if multiplayer.is_server() and game_started:
		rpc_id(id, "kick_player", "Game already in progress")
		multiplayer.multiplayer_peer.disconnect_peer(id)
		return
	
	# Add player to connected list and update all clients
	if multiplayer.is_server():
		connected_players[id] = "Player " + str(id)
		rpc("update_player_list", connected_players)
		# Send server seed to the newly connected client
		rpc_id(id, "set_server_seed", server_seed)

func _on_peer_disconnected(id: int):
	print("Peer disconnected: ", id)
	if multiplayer.is_server():
		connected_players.erase(id)
		rpc("update_player_list", connected_players)
		# If in game, remove the player
		if game_started:
			rpc("remove_player", id)

func _on_connected():
	print("Connected to server")
	# Client loads lobby after connecting
	get_tree().change_scene_to_file("res://ui/lobby.tscn")

func _on_connect_failed():
	print("Connection failed")

func _on_server_disconnected():
	print("Server disconnected")
	# Clean up all players when server disconnects
	get_tree().call_group("players", "queue_free")
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

@rpc("any_peer", "call_local", "reliable")
func update_player_list(players: Dictionary):
	connected_players = players
	# Update lobby UI if it exists
	var lobby = get_tree().get_root().get_node_or_null("Lobby")
	if lobby and lobby.has_method("update_player_list"):
		lobby.update_player_list(players)

@rpc("any_peer", "reliable")
func kick_player(reason: String):
	print("Kicked from server: ", reason)
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

@rpc("any_peer", "call_local", "reliable")
func start_game():
	game_started = true
	get_tree().change_scene_to_file("res://assets/world/main.tscn")
	# Wait a frame to ensure scene is loaded
	await get_tree().process_frame
	# Ensure all clients have the server seed before spawning players
	if multiplayer.is_server():
		rpc("set_server_seed", server_seed)
		for player_id in connected_players.keys():
			rpc("spawn_player", player_id)

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

@rpc("authority", "call_local", "reliable")
func set_server_seed(seeds: int):
	server_seed = seeds
	print("Server seed updated: ", server_seed)
