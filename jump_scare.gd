extends Control

func  _ready() -> void:
	hide()

func jump_scare():
	show()
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.play("jump_scare")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	hide()
