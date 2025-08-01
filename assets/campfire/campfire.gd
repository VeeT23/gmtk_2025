extends StaticBody2D

var branches = {
	"branch": 0
}

func _ready() -> void:
	$Sprite2D/AnimationPlayer.play("fire")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("Player"):
				if body.is_multiplayer_authority():
					if "branch" in get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory and get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory["branch"] >= 1:
						branches["branch"] += get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory["branch"]
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory["branch"] -= 1
						$PointLight2D.texture_scale += 1
						$Label.text = "Branches: " + str(branches["branch"]) + " / 10"
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").update_item_list()
				break
