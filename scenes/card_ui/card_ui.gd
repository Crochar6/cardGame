class_name CardUI
extends Control

@export var card: Card: set = _set_card
@export var char_stats: CharacterStats : set = _set_char_stats

@export var title: String
var energy_cost: int
var description: String

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
var tween_trigger1: Tween
var tween_trigger2: Tween

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2
var mouse_pos_offset: Vector2

var dragable: bool = true

var normal_scale: float = 1
var hover_scale: float = 1.2

@onready var card_ui: Control = $CardUiComponent
@onready var title_label = $TitleLabel

@onready var drag_component = $DragComponent
@onready var hover_component = $HoverComponent

@onready var card_state_machine: CardStateMachine = $StateMachine as CardStateMachine
@onready var drop_point_detector: Area2D = $DropPointDetector

@onready var targets: Array[Node] = []

var playable := true : set = _set_playable
var disabled := false
var queued_play := false

var parent: Node
var tween_position: Tween
var pending_callback: Callable = Callable()

var remaining_triggers: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#drag_component.start_dragging.connect(self.start_following_mouse)
	#drag_component.stop_dragging.connect(self.stop_following_mouse)
	
	Events.card_aim_started.connect(_on_card_drag_or_aiming_started)
	Events.card_drag_started.connect(_on_card_drag_or_aiming_started)
	Events.card_aim_ended.connect(_on_card_drag_or_aiming_ended)
	Events.card_drag_ended.connect(_on_card_drag_or_aiming_ended)
	
	hover_component.hovered.connect(self._hovered)
	hover_component.start_hovering.connect(self._on_start_hover)
	hover_component.stop_hovering.connect(self._on_stop_hover)
	
	card_state_machine.init(self)

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)
	
func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()

func _set_card(value: Card):
	if not is_node_ready():
		await ready
	card = value
	card_ui.set_energy_cost(card.cost)
	card_ui.set_foreground_texture(card.art)
	card_ui.set_background_texture(card.rarity)
	title_label.text = self.card.title

func trigger_animation():
	kill_tween_if_exists(tween_trigger1)
	kill_tween_if_exists(tween_trigger2)
	
	tween_trigger1 = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC).set_parallel(false)
	tween_trigger1.tween_property(card_ui, "rotation", 180*7, 1)
	
	tween_trigger2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_trigger2.tween_property(card_ui, "rotation", 0, 1)
	
	await tween_trigger2.finished
	return true

func get_player():
	return get_tree().get_first_node_in_group('player')

func _play_effect() -> void:
	if not card:
		print("HAD NO CARD ON PLAY card_ui.gd")
		return
	
	card.play(targets, char_stats, get_player())

func resolve_played(callback_next_card: Callable):
	self.pending_callback = callback_next_card
	if card.target == Card.Target.ENEMIES:
		card_state_machine.current_state.transition_requested.emit(card_state_machine.current_state, CardState.State.AIMING)
	else:
		triggered_on_enemy()

func queue_play():
	queued_play = true
	self.card.use_resources(char_stats)
	self.remaining_triggers = self.card.trigger_num

func dequeue_play():
	var legal = self.card.undo_use_resources(char_stats)
	if legal:
		queued_play = false
	return legal

func triggered_on_enemy():
	remaining_triggers -= 1
	_play_effect()
	var return_val = await trigger_animation()
	if remaining_triggers > 0:
		resolve_played(self.pending_callback)
	else:
		self.pending_callback.call()

func _set_playable(value: bool):
	playable = value
	card_ui.set_playable(playable)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(_on_char_stats_changed)

func _on_card_drag_or_aiming_started(used_card: CardUI):
	if used_card == self:
		return
	disabled = true

func _on_card_drag_or_aiming_ended(used_card: CardUI):
	# REALMENT CAL? NO S'ACTIVA JA A ON CHAR STATS SCHANGED?
	disabled = false
	if used_card == self:
		pass
	if not queued_play:
		self.playable = char_stats.can_play_card(card)

func _on_char_stats_changed() -> void:
	if not queued_play:
		self.playable = char_stats.can_play_card(card)

func set_parent(where):
	self.parent = where
	self.reparent(where, false)

func reparent_requested():
	if not self.parent:
		return
	self.reparent(self.parent)

func set_dragable (dragable: bool):
	self.dragable = dragable

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#follow_mouse(delta)
	rotate_velocity(delta)
	pass
	
func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween_position = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween_position.tween_property(self, "global_position", new_position, duration)
		
func rotate_velocity(delta: float) -> void:
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

func set_card_pivot_offset(new_pivot: Vector2):
	self.pivot_offset = new_pivot
	self.card_ui.pivot_offset = new_pivot
	

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
	kill_tween_if_exists(tween_handle)
	tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_handle.tween_property(card_ui, "rotation", 0.0, 0.3)

func _hovered():
	card_ui._hovered()

func _on_start_hover():
	card_ui._on_start_hover()
	
	# Scale up
	kill_tween_if_exists(tween_hover)
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween_hover.tween_property(self, "scale", Vector2(hover_scale, hover_scale), 0.04)

func _on_stop_hover():
	card_ui._on_stop_hover()
	
	# Reset scale
	kill_tween_if_exists(tween_hover)
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween_hover.tween_property(self, "scale", Vector2(normal_scale, normal_scale), 0.1)

func kill_tween_if_exists(tween: Tween):
	if tween and tween.is_running():
		tween.kill()

func _on_drop_point_detector_area_entered(area):
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_detector_area_exited(area):
	targets.erase(area)
