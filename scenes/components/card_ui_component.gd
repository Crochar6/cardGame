extends Control

@onready var scale_node = $ScaleDown

@onready var background_texture_node : TextureRect = $ScaleDown/BackgroundTexture
@onready var card_texture_node : TextureRect = $ScaleDown/Texture
@onready var shadow : TextureRect = $ScaleDown/Shadow
@export var energy_icon_scene : PackedScene
@onready var energy_cost_container: Container = $EnergyCostContainer

var tween_rot: Tween
var tween_shadow_height: Tween
var tween_shadow_opacity: Tween

var max_offset_shadow: float = 5
var height_shadow_normal: float = 6
var height_shadow_hover: float = 26

var opacity_shadow_normal: float = 0.33
var opacity_shadow_hover: float = 0.22

var angle_x_max: float = deg_to_rad(4.0)
var angle_y_max: float = deg_to_rad(4.0)

var following_mouse: bool = false

func set_playable(value: bool):
	if value:
		self.modulate.a = 1
	else:
		self.modulate.a = 0.4

func _ready():
	shadow.position.y = height_shadow_normal
	shadow.self_modulate.a = opacity_shadow_normal
	
func set_fake_3d(x_rot: float, y_rot: float):
	scale_node.material.set_shader_parameter("x_rot", x_rot)
	scale_node.material.set_shader_parameter("y_rot", y_rot)
	
func set_energy_cost(cost: int):
	for n in energy_cost_container.get_children():
		energy_cost_container.remove_child(n)
		n.queue_free() 
	for i in range(cost):
		var energy_symbol = energy_icon_scene.instantiate()
		energy_cost_container.add_child(energy_symbol)

func set_foreground_texture(art: Texture2D):
	card_texture_node.texture = art

func set_background_texture(rarity: Card.Rarity):
	background_texture_node.texture = Card.get_bg_by_rarity(rarity)

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
	var mouse_pos: Vector2 = card_texture_node.get_local_mouse_position()
	var diff: Vector2 = (card_texture_node.position + card_texture_node.size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, card_texture_node.size.x, 1, 0)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, card_texture_node.size.y, 1, 0)
	

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
	
	tween_rot.tween_property(scale_node.material, "shader_parameter/x_rot", 0.0, 0.4)
	tween_rot.tween_property(scale_node.material, "shader_parameter/y_rot", 0.0, 0.4)
	
	kill_tween_if_exists(tween_shadow_height)
	tween_shadow_height = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_height.tween_property(shadow, "position:y", height_shadow_normal, 0.1)
	
	kill_tween_if_exists(tween_shadow_opacity)
	tween_shadow_opacity = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_opacity.tween_property(shadow, "self_modulate:a", opacity_shadow_normal, 0.1)

		
func _on_start_hover():
	kill_tween_if_exists(tween_shadow_height)
	tween_shadow_height = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_height.tween_property(shadow, "position:y", height_shadow_hover, 0.04)
	
	kill_tween_if_exists(tween_shadow_opacity)
	tween_shadow_opacity = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_shadow_opacity.tween_property(shadow, "self_modulate:a", opacity_shadow_hover, 0.04)
	
func kill_tween_if_exists(tween: Tween):
	if tween and tween.is_running():
		tween.kill()
