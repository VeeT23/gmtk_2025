extends Area2D

var loot_contents = {
	"branch": 1,
}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in get_overlapping_bodies():
			if body.is_in_group("Player"):
				if body.is_multiplayer_authority():
					
					for item in loot_contents.keys():
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory[item] += loot_contents[item]
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").update_item_list()
					get_tree().call_group("Enemy", "go_to",global_position)
					get_tree().get_root().get_node("World/CanvasLayer/ButtonTip").clear_tip()
					rpc("sync_looted_open")
					break

@rpc("any_peer", "call_local")
func sync_looted_open():
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_multiplayer_authority(): return
	get_tree().get_root().get_node("World/CanvasLayer/ButtonTip").show_tip("e")


func _on_body_exited(body: Node2D) -> void:
	if not body.is_multiplayer_authority(): return
	get_tree().get_root().get_node("World/CanvasLayer/ButtonTip").clear_tip()
