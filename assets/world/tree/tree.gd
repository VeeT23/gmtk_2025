extends StaticBody2D



func group_members_in_area(group):
	var result = []
	var bodies = $TransparencyArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group(group):
			result.append(body)
	return result


func _on_transparency_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	if not body.is_multiplayer_authority(): return
	$AnimationPlayer.play("fade")


func _on_transparency_area_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	if not body.is_multiplayer_authority(): return
	$AnimationPlayer.play_backwards("fade")
