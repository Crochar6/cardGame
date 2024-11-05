extends Control

@onready var card_play_area = $BattleUi/CardPlayArea

var current_card: int = 0
var cards: Array[CardUI]

func _ready():
	Events.play_cards.connect(resolve_cards)

func resolve_cards():
	current_card = 0
	cards = card_play_area.get_played_cards()
	for card in cards:
		card.set_dragable(false)
	if cards:
		trigger_next_card()
	
func trigger_next_card():
	var card := cards[current_card]
	current_card += 1
	var callback: Callable = func():
		pass
	if current_card < cards.size():
		callback = trigger_next_card
	else:
		# It's the last card
		callback = enable_cards
	card.resolve_played(callback)

func enable_cards():
	for card in cards:
		card.set_dragable(true)
	
	
	
	
	
