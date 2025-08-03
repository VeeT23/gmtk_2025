extends TextureButton

const frame_0: AtlasTexture = preload("res://ui/button/button_sprites/button_frames/button0.tres")
const frame_1: AtlasTexture = preload("res://ui/button/button_sprites/button_frames/button1.tres")
const frame_2: AtlasTexture = preload("res://ui/button/button_sprites/button_frames/button2.tres")
const frame_3: AtlasTexture = preload("res://ui/button/button_sprites/button_frames/button3.tres")
const frame_4: AtlasTexture = preload("res://ui/button/button_sprites/button_frames/button4.tres")
const frame_5: AtlasTexture = preload("res://ui/button/button_sprites/button_frames/button5.tres")

const frames = [frame_0,frame_1,frame_2,frame_3,frame_4,frame_5]

var current_frame = 0

var sticky : bool = false
var is_button_hovered : bool = false

func _ready() -> void:
	$Label.size = size

func set_text(new_text : String):
	$Label.text = new_text

func _on_button_down() -> void:
	#if pressed_flag: return
	#pressed_flag = true
	#if sticky:
		#texture_normal = pressed_texture
		#texture_hover = pressed_texture
	#lbl.position = lbl.position + Vector2(0,2)
	pass


func _on_button_up() -> void:
	#if not sticky:
		#lbl.position = lbl.position - Vector2(0,2)
		#pressed_flag = false
	pass

func update_frame(frame : int) -> void:
	texture_normal = frames[clamp(frame, 0, frames.size() - 1)]

func _on_resized() -> void:
	$Label.size = self.size

func _on_mouse_entered() -> void:
	is_button_hovered = true

func _on_timer_timeout() -> void:
	if is_button_hovered:
		current_frame = clamp(current_frame + 1,  0, frames.size() - 1)
	else:
		current_frame = clamp(current_frame - 1,  0, frames.size() - 1)
	update_frame(current_frame)


func _on_mouse_exited() -> void:
	is_button_hovered = false
