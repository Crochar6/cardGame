extends CardState


func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready
		
	if card_ui.tween_position and card_ui.tween_position.is_running():
		card_ui.tween_position.kill()
	
	card_ui.reparent_requested()
	#card_ui.pivot_offset = card_ui.size / 2
	Events.tooltip_hide_requested.emit()

func on_gui_input(event: InputEvent) -> void:
	# Check if it can be played
	if card_ui.disabled:
		return
		
	if event.is_action_pressed("left_mouse"):
		#card_ui.set_card_pivot_offset(card_ui.get_global_mouse_position() - card_ui.global_position)
		transition_requested.emit(self, CardState.State.CLICKED)

func on_mouse_entered() -> void:
	Events.card_tooltip_requested.emit(card_ui.card.art, card_ui.card.tooltip)

func on_mouse_exited() -> void:
	Events.tooltip_hide_requested.emit()
