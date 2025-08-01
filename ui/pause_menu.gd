extends Control

const main_menu_path : String = "res://ui/main_menu.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide() 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_menu"): #Escape button
		if visible:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_save_button_pressed() -> void:
	SaveManager.save_game()

func _on_load_button_pressed() -> void:
	SaveManager.load_game()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)
