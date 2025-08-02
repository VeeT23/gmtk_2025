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
			if body.is_in_group("Player"):
				if body.is_multiplayer_authority():
					# Client or host with authority interacts
					var inventory = get_tree().get_root().get_node("World/CanvasLayer/Inventory")
					if "branch" in inventory.inventory and inventory.inventory["branch"] >= 1:
						# Request server to add branch
						rpc_id(1, "request_add_branch") # Call server
				break

# Server-only function to handle branch addition
@rpc("any_peer", "call_local")
func request_add_branch():
	if not is_multiplayer_authority():
		return # Only server processes this
	var inventory = get_tree().get_root().get_node("World/CanvasLayer/Inventory")
	if "branch" in inventory.inventory and inventory.inventory["branch"] >= 1:
		print("ADDED")
		branches += 1
		inventory.inventory["branch"] -= 1
		$PointLight2D.texture_scale += 1
		$Label.text = "Branches: " + str(branches) + " / 5"
		strength = branches * 100 + 400
		inventory.update_item_list()
		checkfinish()
		# Sync updated state to all clients
		rpc("sync", branches, $PointLight2D.texture_scale)

func checkfinish():
	if branches >= 5:
		get_tree().get_root().get_node("World").reset_scene()

# RPC to synchronize state across all peers
@rpc("any_peer", "call_local")
func sync(new_branches: int, new_texture_scale: float):
	branches = new_branches
	$PointLight2D.texture_scale = new_texture_scale
	$Label.text = "Branches: " + str(branches) + " / 5"

func _physics_process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	for player in players:
		if player.is_multiplayer_authority():
			if player.global_position.y < global_position.y:
				z_index = 4
			else:
				z_index = 1


func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
