extends Control

@onready var card_play_area = $BattleUi/CardPlayArea

func _ready():
	Events.play_cards.connect(resolve_cards)

func resolve_cards():
	var cards: Array[CardUI] = card_play_area.get_played_cards()
	print(cards)
	for card in cards:
		card.resolve_played()
