extends Node2D

@onready var deck_label: Label = $Deck/DeckLabel
@onready var discard_label: Label = $Discards/DiscardLabel
@onready var char_stats: CharacterStats: set = set_character_stats

func _ready():
	Events.card_discarded.connect(update_stats)
	Events.card_drawn.connect(update_stats)

func update_stats():
	deck_label.text = str(char_stats.draw_pile.cards.size())
	discard_label.text = str(char_stats.discard.cards.size())
	

func set_character_stats(value: CharacterStats):
	char_stats = value
	if not char_stats.stats_changed.is_connected(update_stats):
		char_stats.stats_changed.connect(update_stats)
	update_stats()
