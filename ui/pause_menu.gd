extends Control

func _ready() -> void:
	hide() 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_menu"): #Escape button
		if visible:
			hide()
		else:
			show()
