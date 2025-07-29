extends Node2D

const transition_time : float = 0.5

const main_scene_path : String = "res://assets/world/main.tscn"
const button_size : Rect2 = Rect2(-46,-12,92,24)

@onready var start_button : Sprite2D = $StartButton
@onready var load_button : Sprite2D = $LoadButton
@onready var options_button : Sprite2D = $OptionsButton
@onready var quit_button : Sprite2D = $QuitButton
@onready var animation_player : AnimationPlayer = $CanvasLayer/Overlay/Fade/AnimationPlayer

func _ready() -> void:
	animation_player.speed_scale = 1.0 / transition_time
	animation_player.play("fade_in")
	

func is_mouse_over_button(button_node : Sprite2D, mouse_position : Vector2) -> bool:
	return button_size.has_point(button_node.to_local(mouse_position))

func _input(event: InputEvent) -> void: 
	var mouse_position = get_global_mouse_position()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_mouse_over_button(start_button, mouse_position):
			start_button.frame_coords.x = 2
			animation_player.play("fade_out")
			await get_tree().create_timer(transition_time).timeout
			get_tree().change_scene_to_file(main_scene_path)
		elif is_mouse_over_button(load_button, mouse_position):
			load_button.frame_coords.x = 2 #TODO: add load feature
			animation_player.play("fade_out")
			await get_tree().create_timer(transition_time).timeout
			SaveManager.load_game()
		elif is_mouse_over_button(options_button,mouse_position):
			options_button.frame_coords.x = 2 #TODO: add options
		elif is_mouse_over_button(quit_button, mouse_position):
			quit_button.frame_coords.x = 2
			animation_player.play("fade_out")
			await get_tree().create_timer(transition_time).timeout
			get_tree().quit()
		
	elif event is InputEventMouseMotion:
		for button in [start_button, load_button, options_button, quit_button]: #Handles button highlights
			if button.frame_coords.x != 2:
				button.frame_coords.x = int(!is_mouse_over_button(button, mouse_position))
