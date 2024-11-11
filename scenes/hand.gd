class_name Hand
extends CardHolderArea

@export var char_stats: CharacterStats
@onready var card_ui := preload("res://scenes/card_ui/card_ui.tscn")

func add_card(card: Card) -> void:
	var new_card_ui : CardUI = card_ui.instantiate()
	self.container.add_child(new_card_ui)
	new_card_ui.card = card
	new_card_ui.parent = self.container
	new_card_ui.char_stats = char_stats
	
func discard_card(card: CardUI) -> void:
	card.queue_free()

func disable_hand() -> void:
	for card in get_played_cards():
		card.disabled = true

func enable_hand() -> void:
	for card in get_played_cards():
		card.disabled = false
