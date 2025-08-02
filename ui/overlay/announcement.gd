extends Control


func _ready() -> void:
	$Fade.color = Color(0,0,0,255)
	$Fade2.color = Color(0,0,0,255)
	await get_tree().create_timer(1).timeout
	$Fade/AnimationPlayer.play("fade_in")
	await get_tree().create_timer(2).timeout
	$Fade/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1).timeout
	$Fade.hide()
	$Label.hide()
	$Fade2/AnimationPlayer.play("fade_in")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("animation_cancel"):
		$Fade.hide()
		$Fade2.hide()
		$Label.hide()

func announce(text: String):
	$Fade.color = Color(0,0,0,0)
	$Fade2.color = Color(0,0,0,0)
	$Fade.show()
	$Fade2.show()
	$Fade/AnimationPlayer.play("fade_out")
	$Fade2/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1).timeout
	$Label.show()
	$Label.text = text
	$Fade/AnimationPlayer.play("fade_in")
	await get_tree().create_timer(2).timeout
	$Fade/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1).timeout
	$Fade.hide()
	$Label.hide()
	$Fade2/AnimationPlayer.play("fade_in")

func announce_constant(text: String):
	$Fade.color = Color(0,0,0,0)
	$Fade2.color = Color(0,0,0,0)
	$Fade.show()
	$Fade2.show()
	$Fade/AnimationPlayer.play("fade_out")
	$Fade2/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(1).timeout
	$Label.show()
	$Label.text = text
	$Fade/AnimationPlayer.play("fade_in")
