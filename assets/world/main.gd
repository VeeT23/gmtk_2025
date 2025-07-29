extends Node2D

var player_resource = preload("res://assets/player/player.tscn")

func spawn_player(id: int):
	var player_scene = player_resource.instantiate()
	player_scene.id = id
	add_child(player_scene)

func remove_player(id: int):
	for child in get_children():
		if child.is_in_group("Player"):
			if child.id == id:
				child.queue_free()
