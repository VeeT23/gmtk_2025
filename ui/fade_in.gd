extends Control


func _ready() -> void:
	$Fade.color = Color(0,0,0,255)
	await get_tree().create_timer(1).timeout
	$Fade/AnimationPlayer.play("fade_in")
