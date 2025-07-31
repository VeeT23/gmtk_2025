extends Area2D

var activated = false
var transition_time: float = 4.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		$Sprite2D.frame = 1
		body.actual_speed = 0
		await get_tree().create_timer(transition_time).timeout
		body.actual_speed = body.SPEED
		queue_free()
