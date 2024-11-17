extends CardState


func enter() -> void:
	if not card_ui.targets.is_empty():
		Events.tooltip_hide_requested.emit()
		if card_ui.targets.size() > 1:
			print('MORE THAN ONE TARGET /!\\')
		if card_ui.targets[0] is CardHolderArea:
			print('CardHolder target on CardReleaseAim state!!')
			return
		
		card_ui.triggered_on_enemy()
			

func exit() -> void:
	Events.card_drag_ended.emit(card_ui)
	
func on_input(_event: InputEvent) -> void:
	transition_requested.emit(self, CardState.State.BASE)
