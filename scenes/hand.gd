class_name Hand
extends HBoxContainer


func _ready():
	for child in get_children():
		var card_ui := child as CardUI
		card_ui.set_parent(self)
