class_name CharacterStats
extends Stats

@export var starting_deck: CardPile
@export var cars_per_turn: int
@export var max_energy: int

var energy: int: set = set_energy
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile

func set_energy(value: int) -> void:
	energy = value
	stats_changed.emit()

func reset_energy() -> void:
	self.energy = max_energy
	
func can_play_card(card: Card) -> bool:
	return energy >= card.cost
	
func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.hp = max_hp
	instance.sp = max_sp
	instance.reset_energy()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()

	return instance
