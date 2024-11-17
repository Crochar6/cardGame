class_name BattleUI
extends CanvasLayer

@export var char_stats: CharacterStats: set = _set_char_stats

@onready var card_play_area: CardHolderArea = $CardPlayArea
@onready var hand: Hand = $Hand as Hand
@onready var energy_ui: EnergyUI = $EnergyUI as EnergyUI
@onready var end_turn_button = $EndTurnButton
@onready var reshuffle_button = $ReshuffleButton


func _ready() -> void:
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	Events.card_queued.connect(_on_card_queued)
	Events.card_dequeued.connect(_on_card_dequeued)
	
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	reshuffle_button.pressed.connect(_on_reshuffle_button_pressed)
	
	

func _on_player_hand_drawn() -> void:
	end_turn_button.disabled = false
	reshuffle_button.disabled = false
	pass
	
func _on_end_turn_button_pressed() -> void:
	reshuffle_button.disabled = true
	end_turn_button.disabled = true
	Events.player_turn_ended.emit()
	pass

func _on_card_queued(_card: Card) -> void:
	reshuffle_button.disabled = true
func _on_card_dequeued(_card: Card) -> void:
	reshuffle_button.disabled = card_play_area.get_played_cards().size() > 0
	
func _on_reshuffle_button_pressed() -> void:
	reshuffle_button.disabled = true
	end_turn_button.disabled = true
	Events.player_reshuffle.emit()
	pass

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	
	energy_ui.char_stats = char_stats
	hand.char_stats = char_stats
