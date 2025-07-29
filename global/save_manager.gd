#Singleton script named SaveManager
extends Node

const main_scene_path : String = "res://assets/world/main.tscn"
var player_data = {
	"ip":"",
	"pos_x":0,
	"pos_y":0
}

var save_data = {}

func save_game() -> void:
	var file = FileAccess.open("res://save.json", FileAccess.WRITE)
	
	file.store_var(save_data)
	file.close()

func load_game() -> void:
	var file = FileAccess.open("res://save.json", FileAccess.READ) 
	if file:
		save_data = file.get_var()
		get_tree().change_scene_to_file(main_scene_path)
		file.close()
