extends Node2D
var player_scene: PackedScene = preload("res://assets/player/player.tscn")

var players := {}

func _ready() -> void:
	# Add this node to a group for easier access
	add_to_group("World")
	
	if Network.is_hosting:
		Network.create_server()
	else:
		Network.join_server()

func spawn_player(id: int):
	print("Spawning player with ID: ", id)
	if players.has(id): 
		print("Player ", id, " already exists")
		return
		
	var p = player_scene.instantiate()
	p.name = "Player_%d" % id
	p.add_to_group("players")
	
	# Set authority - the player has authority over their own character
	p.set_multiplayer_authority(id)
	
	players[id] = p
	add_child(p, true)  # Force readable name
	
	print("Player spawned: ", p.name, " at path: ", p.get_path())

func remove_player(id: int):
	if players.has(id):
		print("Removing player: ", id)
		players[id].queue_free()
		players.erase(id)
