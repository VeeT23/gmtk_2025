extends Control

func _ready() -> void:
	hide() 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_menu"): #Escape button
		if visible:
			hide()
		else:
			show()
	

func _on_resume_button_pressed() -> void:
	hide()

func _on_save_button_pressed() -> void:
	SaveManager.save_game()

func _on_load_button_pressed() -> void:
	SaveManager.load_game()

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
