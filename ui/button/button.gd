extends TextureButton


@onready var normal_texture = preload("res://ui/button/button_sprites/button.tres")
@onready var pressed_texture = preload("res://ui/button/button_sprites/button_pressed.tres")
@onready var lbl = $Label

var sticky : bool = false
var pressed_flag : bool = false

func _ready() -> void:
	lbl.size = size

func set_text(new_text : String):
	lbl.text = new_text

func _on_button_down() -> void:
	if pressed_flag: return
	pressed_flag = true
	if sticky:
		texture_normal = pressed_texture
		texture_hover = pressed_texture
	lbl.position = lbl.position + Vector2(0,2)


func _on_button_up() -> void:
	if not sticky:
		lbl.position = lbl.position - Vector2(0,2)
		pressed_flag = false


func _on_resized() -> void:
	lbl.size = size
