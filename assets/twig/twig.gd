extends Area2D



func _ready() -> void:
	$Sprite2D.frame = randi() % 4


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):return
	get_tree().call_group("Enemy", "go_to",global_position)
	visible = false
	$AudioStreamPlayer2D.pitch_scale = 1 + (randf() - 0.5) / 2
	$AudioStreamPlayer2D.play()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
