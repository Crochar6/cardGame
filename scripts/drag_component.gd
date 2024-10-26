extends Control

signal start_dragging
signal stop_dragging

@export var drag_button: Button

var dragging: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	drag_button.gui_input.connect(self._on_gui_input)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed():
		dragging = true
		start_dragging.emit()
	else:
		dragging = false
		stop_dragging.emit()
		

func _on_gui_input(event: InputEvent):
	handle_mouse_click(event)
