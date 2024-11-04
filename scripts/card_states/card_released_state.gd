extends CardState

var played: bool

func enter() -> void:
	played = false
	if not card_ui.targets.is_empty():
		played = true
		if card_ui.targets.size() > 1:
			print('MORE THAN ONE TARGET /!\\')
		card_ui.set_parent(card_ui.targets[0].get_container())
	
func on_input(_event: InputEvent) -> void:
	if played:
		transition_requested.emit(self, CardState.State.BASE)
		return
	transition_requested.emit(self, CardState.State.BASE)
