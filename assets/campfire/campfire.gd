extends StaticBody2D

var strength = 400
var branches = 0

func _ready() -> void:
	$Sprite2D/AnimationPlayer.play("fire")
	# Ensure initial sync for clients joining late
	if is_multiplayer_authority():
		rpc("sync", branches, $PointLight2D.texture_scale)

func _input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("Player") and body.is_multiplayer_authority():
				var inventory = get_tree().get_root().get_node("World/CanvasLayer/Inventory")
				if "branch" in inventory.inventory and inventory.inventory["branch"] >= 1:
					# Deduct branch locally first
					inventory.inventory["branch"] -= 1
					inventory.update_item_list()

					if multiplayer.is_server():
						# Host directly adds the branch
						add_branch()
					else:
						# Client asks the server to add a branch
						rpc_id(1, "request_add_branch")
				break

# Called on server when a client requests branch addition
@rpc("any_peer")
func request_add_branch():
	if not multiplayer.is_server():
		return # Only server handles this
	add_branch()

# Handles branch logic (server only)
func add_branch():
	branches += 1
	$PointLight2D.texture_scale += 1
	$Label.text = "Branches: " + str(branches) + " / 5"
	strength = branches * 100 + 400
	checkfinish()
	# Sync updated state to all clients
	rpc("sync", branches, $PointLight2D.texture_scale)

func checkfinish():
	if branches >= 5:
		# Only send the RPC to reset the scene on all clients (including server)
		rpc("sync_finish")

# RPC to synchronize state across all peers
@rpc("any_peer", "call_local")
func sync(new_branches: int, new_texture_scale: float):
	branches = new_branches
	$PointLight2D.texture_scale = new_texture_scale
	$Label.text = "Branches: " + str(branches) + " / 5"
	

@rpc("any_peer", "call_local")
func sync_finish():
	get_tree().get_root().get_node("World").reset_scene()

func _physics_process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		if player.is_multiplayer_authority():
			z_index = 4 if player.global_position.y < global_position.y else 1

func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
