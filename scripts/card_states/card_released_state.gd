extends CardState

var played: bool

func enter() -> void:
	played = false
	if not card.targets.is_empty():
		played = true
		print("play card for target(s)", card.targets)
	
func on_input(_event: InputEvent) -> void:
	if played:
		return
	transition_requested.emit(self, CardState.State.BASE)
