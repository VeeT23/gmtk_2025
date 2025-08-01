extends Node2D

const transition_time : float = 0.5
const main_scene_path : String = "res://assets/world/main.tscn"

@onready var animation_player : AnimationPlayer = $CanvasLayer/Overlay/Fade/AnimationPlayer

@onready var main_screen : VBoxContainer = $CanvasLayer/Menus/Main
@onready var start_button : TextureButton = main_screen.get_node("StartButton")
@onready var options_button : TextureButton = main_screen.get_node("OptionsButton")
@onready var quit_button : TextureButton = main_screen.get_node("QuitButton")

@onready var start_screen : VBoxContainer = $CanvasLayer/Menus/Start
@onready var new_button : TextureButton = start_screen.get_node("NewButton")
@onready var load_button : TextureButton = start_screen.get_node("LoadButton")
@onready var multiplayer_button : TextureButton = start_screen.get_node("MultiplayerButton")


@onready var multiplayer_screen : HBoxContainer = $CanvasLayer/Menus/Join
@onready var join_button : TextureButton = multiplayer_screen.get_node("JoinButton")
@onready var address_box : LineEdit = multiplayer_screen.get_node("AddressBox")

func _ready() -> void:
	animation_player.speed_scale = 1.0 / transition_time
	animation_player.play("fade_in")
	
	start_button.set_text("Start")
	options_button.set_text("Options")
	quit_button.set_text("Quit")
	quit_button.sticky = true
	
	new_button.set_text("New")
	load_button.set_text("Load")
	multiplayer_button.set_text("Join")
	new_button.sticky = true
	multiplayer_button.sticky = true
	
	join_button.set_text("Join")
	join_button.sticky = true

func _on_quit_button_pressed() -> void:
	animation_player.play("fade_out")
	await get_tree().create_timer(transition_time).timeout
	get_tree().quit()

func _on_start_button_pressed() -> void:
	main_screen.hide()
	start_screen.show()

func _on_new_button_pressed() -> void:
	animation_player.play("fade_out")
	await get_tree().create_timer(transition_time).timeout
	Network.is_hosting = true
	Network.create_server()

func _on_join_button_pressed() -> void:
	Network.ip = address_box.text
	animation_player.play("fade_out")
	await get_tree().create_timer(transition_time).timeout
	Network.join_server()


func _on_multiplayer_button_pressed() -> void:
	start_screen.hide()
	multiplayer_screen.show()
