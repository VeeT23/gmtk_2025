extends Node2D

const DAY_DURATION_MINUTES : float = 1.0

const PLAYER_SCENE : PackedScene = preload("res://assets/player/player.tscn")
const TWIG_SCENE : PackedScene = preload("res://assets/twig/twig.tscn")
const TREE_SCENE : PackedScene = preload("res://assets/world/tree/tree.tscn")

@onready var terrain_tilemap: TileMapLayer = $Terrain
@onready var extras_tilemap: TileMapLayer = $ExtrasAutoPlace

var rng = RandomNumberGenerator.new()
var players := {}

var current_day : int = 1

func _ready() -> void:
	$CanvasLayer.show()
	if Network.is_hosting:
		Network.create_server()
		rng.randomize()
		place_twigs()
		place_trees()
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
	current_day += 1
	$CanvasLayer/Announcement.announce("Day " + str(current_day))
	await  get_tree().create_timer(1).timeout
	get_tree().call_group("Loot", "reset")
	$DayNightTimer.start(DAY_DURATION_MINUTES * 60.0)
	
	

func _process(_delta: float) -> void:
	$GlobalIllumination.color.a = remap($DayNightTimer.time_left, DAY_DURATION_MINUTES * 60,0,0,1)

func _on_day_night_timer_timeout() -> void:
	$CanvasLayer/Announcement.announce("Night " + str(current_day))

func place_twigs():
	var used_cells = terrain_tilemap.get_used_cells_by_id(1)
	for cell in used_cells:
		if rng.randf() < 0.5:
			add_twig(cell)

func add_twig(pos: Vector2):
	var twig = TWIG_SCENE.instantiate()
	var tile_size = terrain_tilemap.tile_set.tile_size.x
	var real_pos = pos * terrain_tilemap.scale.x * tile_size
	var offset_pos = Vector2(rng.randi_range(-tile_size / 2.0, tile_size / 2.0),rng.randi_range(-tile_size / 2.0, tile_size / 2.0))
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
