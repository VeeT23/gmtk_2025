extends StaticBody2D

func _ready() -> void:
	var path_finding_mask : TileMapLayer = get_tree().get_root().get_node("World/PathfindingMask")
	var tile_coord : Vector2i = path_finding_mask.local_to_map(path_finding_mask.to_local(global_position))
	path_finding_mask.erase_cell(tile_coord)


func _on_transparency_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	if not body.is_multiplayer_authority(): return
	$AnimationPlayer.play("fade")

func _on_transparency_area_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	if not body.is_multiplayer_authority(): return
	$AnimationPlayer.play_backwards("fade")

func _physics_process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player") #make player and tree layer correctly
	for player in players:
		if player.is_multiplayer_authority():
			if player.global_position.y < global_position.y:
				z_index = 3
			else:
				z_index = 1


func _on_shake_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Enemy"): return
	$Shake/AnimationPlayer.play("shake")
