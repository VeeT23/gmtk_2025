extends Area2D



func _ready() -> void:
	$Sprite2D.frame = randi() % 4


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):return
	get_tree().call_group("Enemy", "go_to",global_position)
	queue_free()
