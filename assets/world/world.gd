extends Node2D
var player_scene: PackedScene = preload("res://assets/player/player.tscn")

var players := {}

func _ready() -> void:
	Network.create_server()

func spawn_player(id: int):
	print("Spawning player")
	if players.has(id): return
	var p = player_scene.instantiate()
	p.name = "Player_%d" % id
	p.set_multiplayer_authority(id == multiplayer.get_unique_id())
	players[id] = p
	add_child(p)

func remove_player(id: int):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)
