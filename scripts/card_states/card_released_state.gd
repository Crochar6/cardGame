extends CardState

var played: bool

func enter() -> void:
	if not card_ui.targets.is_empty():
		Events.tooltip_hide_requested.emit()
		if card_ui.targets.size() > 1:
			print('MORE THAN ONE TARGET /!\\')
		if card_ui.targets[0] is CardHolderArea:
			var to = card_ui.targets[0]
			var from = card_ui.parent.get_parent()
			if to.is_play_area:
				if not from.is_play_area:
					# QUEUED
					if card_ui.playable:
						card_ui.queue_play()
					else:
						return
			elif not to.is_play_area:
				if from.is_play_area:
					# DE-QUEUED
					card_ui.dequeue_play()
			card_ui.set_parent(to.get_container())
			
		else:
			card_ui.triggered_on_enemy()
			pass

func exit() -> void:
	Events.card_drag_ended.emit(card_ui)
	
func on_input(_event: InputEvent) -> void:
	transition_requested.emit(self, CardState.State.BASE)
