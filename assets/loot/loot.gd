extends StaticBody2D

var looted = false
var loot_contents = {
	"ammo": 25
}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("Player"):
				if body.is_multiplayer_authority():
					for item in loot_contents.keys():
						print(get_tree().get_root().get_tree_string_pretty())
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory[item] += loot_contents[item]
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").update_item_list()
				looted = true
				rpc("sync_looted")
				break

@rpc("any_peer", "call_local")
func sync_looted():
	looted = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
