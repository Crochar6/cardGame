class_name Hand
extends CardHolderArea


func _ready():
	for child in container.get_children():
		var card_ui := child as CardUI
		card_ui.set_parent(self.container)
