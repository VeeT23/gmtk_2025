extends Node2D

const DAY_DURATION_MINUTES : float = 4.0

const PLAYER_SCENE : PackedScene = preload("res://assets/player/player.tscn")
const TWIG_SCENE : PackedScene = preload("res://assets/twig/twig.tscn")
const TREE_SCENE : PackedScene = preload("res://assets/world/tree/tree.tscn")

@onready var terrain_tilemap: TileMapLayer = $Terrain
@onready var extras_tilemap: TileMapLayer = $ExtrasAutoPlace

var rng = RandomNumberGenerator.new()
var players := {}

var current_day : int = 1
var twig_world_initialized = false

func _ready() -> void:
	
	$ExtrasAutoPlace.hide()
	$PathfindingMask.hide()
	
	
	rng.seed = Network.server_seed
	print(rng.seed)
	$CanvasLayer.show()
	place_twigs()
	place_trees()
	if multiplayer.is_server():
		twig_world_initialized = true
		# Spawn all connected players after world is ready
		await get_tree().process_frame
		for player_id in Network.connected_players.keys():
			spawn_player(player_id)
	else:
		# Request world data from server
		rpc_id(1, "request_world_data")
	get_tree().call_group("Obstacle", "new_day", current_day)
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
	if current_day >= 5:
		$CanvasLayer/Announcement.announce_constant("You've Won!")
		$Enemy.global_position = $Enemy.starting_pos
		$Enemy.inactive = true
		$AudioStreamPlayer2D.play()
		await get_tree().create_timer(11).timeout
		get_tree().quit()
	else:
		current_day += 1
		$CanvasLayer/Announcement.announce("Day " + str(current_day))
		await  get_tree().create_timer(1).timeout
		get_tree().call_group("Loot", "reset")
		get_tree().call_group("Obstacle", "new_day", current_day)
		$Enemy.global_position = $Enemy.starting_pos
		$Enemy.inactive = true
		$DayNightTimer.start(DAY_DURATION_MINUTES * 60.0)
	
	

func _process(_delta: float) -> void:
	$GlobalIllumination.color.a = remap($DayNightTimer.time_left, DAY_DURATION_MINUTES * 60,0,0,1)

func _on_day_night_timer_timeout() -> void:
	$Enemy.inactive = false
	$CanvasLayer/Announcement.announce("Night " + str(current_day))

func place_twigs():
	var used_cells = terrain_tilemap.get_used_cells_by_id(1)
	print("Terrain cells found: ", used_cells.size())
	
	for cell in used_cells:
		# Use deterministic seeding for consistent results
		var cell_seed = Network.server_seed + cell.x * 1000 + cell.y
		var temp_rng = RandomNumberGenerator.new()
		temp_rng.seed = cell_seed
		
		if temp_rng.randf() < 0.5:
			add_twig(cell)
	
	print("Twigs placed: ", get_tree().get_nodes_in_group("Loot").size())

func add_twig(pos: Vector2):
	var twig = TWIG_SCENE.instantiate()
	var tile_size = terrain_tilemap.tile_set.tile_size.x
	var real_pos = pos * terrain_tilemap.scale.x * tile_size
	
	# Use deterministic offset based on position
	var pos_seed = Network.server_seed + int(pos.x) * 1000 + int(pos.y)
	var temp_rng = RandomNumberGenerator.new()
	temp_rng.seed = pos_seed
	
	var offset_pos = Vector2(
		temp_rng.randi_range(-tile_size / 2.0, tile_size / 2.0),
		temp_rng.randi_range(-tile_size / 2.0, tile_size / 2.0)
	)
	twig.global_position = offset_pos + real_pos
	add_child(twig)

func place_trees():
	var tree_cells = extras_tilemap.get_used_cells_by_id(1)
	tree_cells.sort_custom(func(a, b): return a.y < b.y)
	for cell in tree_cells:
		add_tree(cell)

func add_tree(pos: Vector2):
	var twig = TREE_SCENE.instantiate()
	var tile_size = extras_tilemap.tile_set.tile_size.x
	var real_pos = pos * extras_tilemap.scale.x * tile_size
	var offset_pos = Vector2(rng.randi_range(-tile_size / 2.0, tile_size / 2.0),rng.randi_range(-tile_size / 2.0, tile_size / 2.0))
	twig.global_position = offset_pos + real_pos
	add_child(twig)

@rpc("any_peer", "reliable")
func request_world_data():
	if multiplayer.is_server():
		var twig_data = []
		var tree_positions = []
		
		# Collect all twig data (position and sprite frame)
		for child in get_children():
			if child.scene_file_path == "res://assets/twig/twig.tscn":
				var twig_info = {
					"position": child.global_position,
					"frame": child.get_node("Sprite2D").frame if child.has_node("Sprite2D") else 0
				}
				twig_data.append(twig_info)
			elif child.name.begins_with("Tree"):  # Or however trees are identified
				tree_positions.append(child.global_position)
		
		var sender_id = multiplayer.get_remote_sender_id()
		rpc_id(sender_id, "receive_world_data", twig_data, tree_positions)

@rpc("any_peer", "reliable")
func receive_world_data(twig_data: Array, tree_positions: Array):
	if twig_world_initialized:
		return
		
	print("Receiving world data: ", twig_data.size(), " twigs, ", tree_positions.size(), " trees")
	
	# Clear only twigs that were spawned by client
	for child in get_children():
		if child.scene_file_path == "res://assets/twig/twig.tscn":
			child.queue_free()
	
	await get_tree().process_frame  # Wait for cleanup
	
	# Spawn twigs at synced positions with correct properties
	for twig_info in twig_data:
		var twig = TWIG_SCENE.instantiate()
		twig.global_position = twig_info.position
		add_child(twig)
		
		# Set the sprite frame after the twig is added to the scene
		await get_tree().process_frame
		if twig.has_node("Sprite2D"):
			twig.get_node("Sprite2D").frame = twig_info.frame
	
	# Spawn trees at synced positions
	for pos in tree_positions:
		var tree = TREE_SCENE.instantiate()
		tree.global_position = pos
		add_child(tree)
	
	twig_world_initialized = true
