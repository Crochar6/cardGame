extends Control

@onready var shadow = $CardTexture/Shadow
@onready var card_texture = $CardTexture
@export var texture: Texture2D

var tween_rot: Tween
var tween_shadow_height: Tween
var tween_shadow_opacity: Tween

var max_offset_shadow: float = 0.8
var height_shadow_normal: float = 6
var height_shadow_hover: float = 16

var opacity_shadow_normal: float = 0.23
var opacity_shadow_hover: float = 0.12

var angle_x_max: float = deg_to_rad(4.0)
var angle_y_max: float = deg_to_rad(4.0)

var following_mouse: bool = false

func _ready():
	card_texture.texture = texture
	
	shadow.position.y = height_shadow_normal
	shadow.self_modulate.a = opacity_shadow_normal
	
func _process(delta):
	handle_shadow(delta)
	if Engine.is_editor_hint():
		card_texture.texture = texture
		
func set_fake_3d(x_rot: float, y_rot: float):
	card_texture.material.set_shader_parameter("x_rot", x_rot)
	card_texture.material.set_shader_parameter("y_rot", y_rot)
	

func handle_shadow(delta: float) -> void:
	# Replace with the actual path to your Camera2D node
	var camera: Camera2D = get_viewport().get_camera_2d()
	
	if not camera:
		return
		
	var camera_position: Vector2 = camera.global_position
	
	# Calculate the world-space "center" based on the camera's zoom and viewport size
	var viewport_size: Vector2 = get_viewport_rect().size
	var world_center_offset = (viewport_size / 2) * camera.zoom

	# Calculate distance using the camera position as the new reference point
	var distance: float = self.global_position.x - camera_position.x

	# Update shadow position based on the world-space offset
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / world_center_offset.x)) * shadow.position.y
	
func _hovered():
	# Handles rotation
	# Get local mouse pos
	var mouse_pos: Vector2 = card_texture.get_local_mouse_position()
	var diff: Vector2 = (card_texture.position + card_texture.size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, card_texture.size.x, 1, 0)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, card_texture.size.y, 1, 0)
	

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	if following_mouse:
		rot_x = 0
		rot_y = 0
	set_fake_3d(rot_y, rot_x)
	
func _on_stop_hover():
	# Reset rotation
	kill_tween_if_exists(tween_rot)
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	
	tween_rot.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.4)
	tween_rot.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.4)
	
	kill_tween_if_exists(tween_shadow_height)
	tween_shadow_height = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_height.tween_property(shadow, "position:y", height_shadow_normal, 0.4)
	
	kill_tween_if_exists(tween_shadow_opacity)
	tween_shadow_opacity = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_opacity.tween_property(shadow, "self_modulate:a", opacity_shadow_normal, 0.4)

func _on_start_hover():
	kill_tween_if_exists(tween_shadow_height)
	tween_shadow_height = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_height.tween_property(shadow, "position:y", height_shadow_hover, 0.4)
	
	kill_tween_if_exists(tween_shadow_opacity)
	tween_shadow_opacity = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_opacity.tween_property(shadow, "self_modulate:a", opacity_shadow_hover, 0.4)
	
func kill_tween_if_exists(tween: Tween):
	if tween and tween.is_running():
		tween.kill()
