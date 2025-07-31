extends Area2D

var activated = false
var transition_time: float = 4.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		animate()
		body.actual_speed = 0
		await get_tree().create_timer(transition_time).timeout
		body.actual_speed = body.SPEED
		queue_free()


func animate():
	$Sprite2D.visible = false
	$Frame2.visible = true
	await get_tree().create_timer(0.2).timeout
	$Frame2.visible = false
	$Frame3.visible = true
