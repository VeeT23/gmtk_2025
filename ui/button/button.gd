extends TextureButton

const texture = preload("res://ui/button/button_sprites/button_new_hover1.tres")
@onready var normal_texture = preload("res://ui/button/button_sprites/button_new.tres")
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
	pass #lbl.size = size

var entered = false
func _on_mouse_entered() -> void:
	if entered: return
	entered = true
	var atlas : AtlasTexture = texture
	for x in 6:
		atlas.region.position = Vector2(128 * x,0)
		texture_normal = atlas
		await get_tree().create_timer(0.1).timeout
		if x == 5: 
			entered = false
