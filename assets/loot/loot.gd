extends StaticBody2D

var looted = false
var loot_contents = {
	"ammo": 25
}

func _input(event: InputEvent) -> void:
	if looted: return
	if event.is_action_pressed("interact"):
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("Player"):
				if body.is_multiplayer_authority():
					
					for item in loot_contents.keys():
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory[item] += loot_contents[item]
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").update_item_list()
				looted = true
				rpc("sync_looted_open")
				break

func reset():
	get_node("Sprite2D").visible = true
	get_node("CollisionShape2D").disabled = false
	get_node("Sprite2D/AnimationPlayer").play("RESET")
	looted = false

@rpc("any_peer", "call_local")
func sync_looted_close():
	$Sprite2D/AnimationPlayer.play("RESET")
	looted = false
	$Sprite2D.visible = true
	$CollisionShape2D.disabled = false

@rpc("any_peer", "call_local")
func sync_looted_open():
	$Sprite2D/AnimationPlayer.play("open_chest")
	looted = true
	await $Sprite2D/AnimationPlayer.animation_finished
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
