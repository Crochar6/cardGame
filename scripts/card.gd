@tool
extends Control

class_name Card

@export var title: String
var energy_cost: int
var description: String

@onready
var state_machine: Node = $StateMachine

var angle_x_max: float = deg_to_rad(3.0)
var angle_y_max: float = deg_to_rad(3.0)

#@export_category("Oscillator")
var spring: float = 110.0
var damp: float = 8.0
var velocity_multiplier: float = 0.09

var displacement: float = 0.0 
var oscillator_velocity: float = 0.0

var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2
var mouse_pos_offset: Vector2

var normal_scale: float = 1
var hover_scale: float = 1.3

@onready var card_ui: Control = $CardUiComponent
@onready var collision_shape = $AreaDetectComponent
@onready var title_label = $TitleLabel

@onready var drag_component = $DragComponent
@onready var hover_component = $HoverComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	#state_machine.init(self)
	
	drag_component.start_dragging.connect(self.start_following_mouse)
	drag_component.stop_dragging.connect(self.stop_following_mouse)
	
	hover_component.hovered.connect(self._hovered)
	hover_component.start_hovering.connect(self._on_start_hover)
	hover_component.stop_hovering.connect(self._on_stop_hover)
	
	print(self.title)
	title_label.text = self.title


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	follow_mouse(delta)
	rotate_velocity(delta)
	
	if Engine.is_editor_hint():
		title_label.text = self.title
	

func rotate_velocity(delta: float) -> void:
	if not following_mouse: return
	var center_pos: Vector2 = global_position - (size/2.0)

	# Compute the velocity
	velocity = (position - last_pos) / delta
	last_pos = position
	
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	card_ui.rotation = displacement

func follow_mouse(delta: float) -> void:
	if not following_mouse: return
	
	var mouse_pos: Vector2 = get_global_mouse_position()

	# Adjust the mouse position by this ratio
	global_position = mouse_pos - mouse_pos_offset

func start_following_mouse():
	self.following_mouse = true
	card_ui.following_mouse = true
	mouse_pos_offset = get_global_mouse_position() - global_position
	top_level = true
	card_ui.set_fake_3d(0.0, 0.0)
	
func stop_following_mouse():
	self.following_mouse = false
	card_ui.following_mouse = false
	top_level = false
	collision_shape.set_deferred("disabled", false)
	kill_tween_if_exists(tween_handle)
	tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_handle.tween_property(card_ui, "rotation", 0.0, 0.3)

func _hovered():
	card_ui._hovered()

func _on_start_hover():
	card_ui._on_start_hover()
	
	# Scale up
	kill_tween_if_exists(tween_hover)
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(hover_scale, hover_scale), 0.5)

func _on_stop_hover():
	card_ui._on_stop_hover()
	
	# Reset scale
	kill_tween_if_exists(tween_hover)
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(normal_scale, normal_scale), 0.4)

func kill_tween_if_exists(tween: Tween):
	if tween and tween.is_running():
		tween.kill()
