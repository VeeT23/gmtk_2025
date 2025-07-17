extends Control

const main_scene_path : String = "res://assets/world/main.tscn"

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(main_scene_path)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
