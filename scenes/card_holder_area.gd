class_name CardHolderArea
extends Area2D

@export var container: Container

func _ready():
	for child in container.get_children():
		var card_ui := child as CardUI
		card_ui.set_parent(self.container)
		
func get_played_cards():
	var child_cards: Array[CardUI]= []
	for child in container.get_children():
		if child is CardUI:
			child_cards.append(child)
	return child_cards

func get_container():
	return self.container
