class_name BattleUI
extends CanvasLayer

@export var char_stats: CharacterStats: set = _set_char_stats

@onready var hand: Hand = $Hand as Hand
@onready var energy_ui: EnergyUI = $EnergyUI as EnergyUI
@onready var end_turn_button = $EndTurnButton

func _ready() -> void:
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	

func _on_player_hand_drawn() -> void:
	end_turn_button.disabled = false
	pass
	
func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	Events.player_turn_ended.emit()
	pass

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	
	energy_ui.char_stats = char_stats
	hand.char_stats = char_stats
