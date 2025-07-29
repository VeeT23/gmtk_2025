#Singleton script named SaveManager
extends Node

var save_data = {
	"test_variable":0
	}

func save_game() -> void:
	var file = FileAccess.open("res://save.json", FileAccess.WRITE)
	
	file.store_var(save_data)
	file.close()

func load_game() -> void:
	var file = FileAccess.open("res://save.json", FileAccess.READ) 
	if file:
		save_data = file.get_var()  # Now this correctly assigns to the class variable
		file.close()
