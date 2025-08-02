extends StaticBody2D


@export var set_frame = 0
var looted = false
var loot_contents = {
	"trap": 1
}

func _ready() -> void:
	$Sprite2D.frame = set_frame

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
					get_tree().get_root().get_node("World/CanvasLayer/ButtonTip").clear_tip()
					rpc("sync_looted_open")
					
					break

func reset():
	get_node("Sprite2D").visible = true
	get_node("CollisionShape2D").disabled = false
	looted = false

@rpc("any_peer", "call_local")
func sync_looted_close():
	looted = false
	$Sprite2D.visible = true
	$CollisionShape2D.disabled = false

@rpc("any_peer", "call_local")
func sync_looted_open():
	$AudioStreamPlayer2D.play()
	looted = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if looted: return
	if not body.is_multiplayer_authority(): return
	get_tree().get_root().get_node("World/CanvasLayer/ButtonTip").show_tip("e")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_multiplayer_authority(): return
	get_tree().get_root().get_node("World/CanvasLayer/ButtonTip").clear_tip()
