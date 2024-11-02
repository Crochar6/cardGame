class_name Hand
extends HBoxContainer


func _ready():
	for child in get_children():
		var card := child as CardDupe
		card.reparent_requested.connect(_on_card_reparent_requested)
	

func _on_card_reparent_requested(child: CardDupe) -> void:
	child.reparent(self)
