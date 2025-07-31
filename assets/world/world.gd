extends Node2D

const DAY_DURATION_MINUTES : float = 1.0

const PLAYER_SCENE : PackedScene = preload("res://assets/player/player.tscn")

var players := {}

var current_day : int = 1

func _ready() -> void:
	# Add this node to a group for easier access
	add_to_group("World")
	
	if Network.is_hosting:
		Network.create_server()
	else:
		Network.join_server()
	
	$DayNightTimer.start(DAY_DURATION_MINUTES * 60.0)

func spawn_player(id: int):
	print("Spawning player with ID: ", id)
	if players.has(id): 
		print("Player ", id, " already exists")
		return
		
	var p = PLAYER_SCENE.instantiate()
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

func reset_scene():
	get_tree().call_group("Loot", "reset")

func _process(_delta: float) -> void:
	$GlobalIllumination.color.a = remap($DayNightTimer.time_left, DAY_DURATION_MINUTES * 60,0,0,1)

func _on_day_night_timer_timeout() -> void:
	$CanvasLayer/Announcement.announce("Night " + str(current_day))
