extends Control

signal start_hovering
signal stop_hovering
signal hovered

@export var drag_button: Button

var dragging: bool = false

func _ready():
	drag_button.mouse_entered.connect(_on_mouse_entered)
	drag_button.mouse_exited.connect(_on_mouse_exited)
	drag_button.gui_input.connect(_on_gui_input)

func _on_mouse_entered():
	start_hovering.emit()

func _on_mouse_exited():
	stop_hovering.emit()

func _on_gui_input(event):
	if not event is InputEventMouseMotion: return
	hovered.emit()
