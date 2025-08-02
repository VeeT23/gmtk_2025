extends Control

const TEXTURE_GRID_SIZE : Vector2i = Vector2i(16,16)
const KEYBOARD_E_COORD : Vector2i = Vector2i(4,2)
const KEYBOARD_E_COORD_PRESSED : Vector2i = Vector2i(4,9)

@onready var texture : AtlasTexture = $TextureRect.texture
@onready var region : Rect2 = texture.region

var is_pressed : bool = false
var current_tip = null

func set_to_atlas_coordinates(coord : Vector2i):
	texture.region = Rect2(Vector2(coord * TEXTURE_GRID_SIZE), texture.region.size)

func clear_tip():
	current_tip = null
	$Timer.stop()
	$TextureRect.hide()

func show_tip(key: String):
	current_tip = key
	is_pressed = false
	update()

func update():
	if not current_tip: return
	$TextureRect.show()
	if current_tip == "e":
		if is_pressed:
			set_to_atlas_coordinates(KEYBOARD_E_COORD_PRESSED)
		else:
			set_to_atlas_coordinates(KEYBOARD_E_COORD)
	
	is_pressed = !is_pressed
	$Timer.start()

func _on_timer_timeout() -> void: update()
