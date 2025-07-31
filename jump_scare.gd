extends Control

func  _ready() -> void:
	$ScaryFace.hide()

func jump_scare():
	$AnimationPlayer.play("jump_scare")
