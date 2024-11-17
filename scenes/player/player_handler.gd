class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.3
const HAND_DISCARD_INTERVAL := 0.3

@export var hand: Hand
@export var discard_area: CardHolderArea

var character: CharacterStats

func _ready():
	Events.card_played.connect(_on_card_played)

func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.duplicate(true)
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	start_turn()

func start_turn() -> void:
	character.reset_energy()
	draw_cards(character.cars_per_turn)

func end_turn() -> void:
	hand.disable_hand()
	discard_cards()


func draw_card() -> void:
	var card: Card = character.draw_pile.draw_card()
	Events.card_drawn.emit()
	hand.add_card(card)

func draw_cards(max_amount: int) -> void:
	
	var on_hand := hand.get_played_cards().size()
	var remaining = character.draw_pile.cards.size()
	var to_draw = min(max_amount - on_hand, remaining)
	to_draw = max(to_draw, 0)
	if to_draw:
		var tween := create_tween()
		for i in range(to_draw):
			tween.tween_callback(draw_card)
			tween.tween_interval(HAND_DRAW_INTERVAL)
		tween.finished.connect(
			func(): Events.player_hand_drawn.emit()
		)
	else:
		Events.player_hand_drawn.emit()

func discard_cards() -> void:
	var cards_to_play = discard_area.get_played_cards()
	var hand_discarded_callback = func hand_discarded():
			Events.player_hand_discarded.emit()
			hand.enable_hand()
			
	if not cards_to_play:
		hand_discarded_callback.call()
		return
	var tween = create_tween()
	for card_ui in cards_to_play:
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_callback(func(): Events.card_discarded.emit())
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	tween.finished.connect(
		hand_discarded_callback
	)

func reshuffle_deck_from_discard() -> void:
	# discard -> draw
	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())
	character.draw_pile.shuffle()

func _on_card_played(card: Card) -> void:
	character.discard.add_card(card)
