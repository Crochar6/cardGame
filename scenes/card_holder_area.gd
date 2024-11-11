class_name CardHolderArea
extends Area2D

@export var container: Container
@export var is_play_area: bool


func get_played_cards() -> Array[CardUI]:
	var child_cards: Array[CardUI]= []
	for child in container.get_children():
		if child is CardUI:
			child_cards.append(child)
	return child_cards

func get_container():
	return self.container
