extends Control

@export var char_stats: CharacterStats

@onready var battle_ui: BattleUI = $BattleUi as BattleUI

@onready var card_play_area = $BattleUi/CardPlayArea

@onready var player_handler: PlayerHandler = $PlayerHandler as PlayerHandler

@onready var player: Player = $Player as Player

var current_card: int = 0
var cards: Array[CardUI]

func _ready():
	Events.player_turn_ended.connect(resolve_cards)
	
	var new_stats: CharacterStats = char_stats.create_instance()
	battle_ui.char_stats = new_stats
	player.stats = new_stats
	
	Events.play_cards_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(player_handler.start_turn)
	
	start_battle(new_stats)

func start_battle(stats: CharacterStats) -> void:
	player_handler.start_battle(stats)

func resolve_cards():
	current_card = 0
	cards = card_play_area.get_played_cards()
	for card in cards:
		card.disabled = true
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
		callback = on_all_cards_triggered
	card.resolve_played(callback)

func on_all_cards_triggered():
	for card in cards:
		card.set_dragable(true)
		card.queue_free()
	Events.play_cards_ended.emit()
	
	
	
	
	
