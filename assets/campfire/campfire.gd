extends StaticBody2D

var strength = 300

var branches = {
	"branch": 0
}

func _ready() -> void:
	$Sprite2D/AnimationPlayer.play("fire")

func _input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		for body in $Area2D.get_overlapping_bodies():
			if body.is_in_group("Player"):
				if body.is_multiplayer_authority():
					if "branch" in get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory and get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory["branch"] >= 1:
						print("ADDED")
						branches["branch"] += 1
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").inventory["branch"] -= 1
						$PointLight2D.texture_scale += 1
						$Label.text = "Branches: " + str(branches["branch"]) + " / 10"
						get_tree().get_root().get_node("World/CanvasLayer/Inventory").update_item_list()
						checkfinish()
				break

func checkfinish():
	if branches["branch"] >= 5:
		get_tree().get_root().get_node("World").reset_scene()
		

func _physics_process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player") #make player and tree layer correctly
	for player in players:
		if player.is_multiplayer_authority():
			if player.global_position.y < global_position.y:
				z_index = 4
			else:
				z_index = 1
