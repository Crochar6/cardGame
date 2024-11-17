class_name Card
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

const CARD_BG_COMMON = preload("res://assets/cards/bg/card_bg_common.png")
const CARD_BG_UNCOMMON = preload("res://assets/cards/bg/card_bg_uncommon.png")
const CARD_BG_RARE = preload("res://assets/cards/bg/card_bg_rare.png")
const CARD_BG_LEGENDARY = preload("res://assets/cards/bg/card_bg_legendary.png")

enum Target {SELF, ENEMIES, MULTI_TRIGGER, ALL_ENEMIES, EVERYONE}

@export_category("Card Attributes")
@export var id: String
@export var title: String
@export var target: Target
@export var trigger_num: int = 1
@export var rarity: Rarity
@export var cost: int
@export_multiline var tooltip: String
@export var has_triger: bool = true

@export_category("Card Visuals")
@export var art: Texture2D

static func get_bg_by_rarity(rarity: Rarity):
	match rarity:
		Rarity.UNCOMMON:
			return CARD_BG_UNCOMMON
		Rarity.RARE:
			return CARD_BG_RARE
		Rarity.LEGENDARY:
			return CARD_BG_LEGENDARY
		_:
			return CARD_BG_COMMON
	

func get_player(targets: Array[Node]) -> Player:
	var player = targets[0].get_tree().get_first_node_in_group('player')
	return player

func is_targeted() -> bool:
	return self.target == Target.ENEMIES

func requires_multi_target() -> bool:
	return self.target == Target.MULTI_TRIGGER

func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return[]
	
	var tree := targets[0].get_tree()
	
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemies")
		Target.EVERYONE:
			return tree.get_nodes_in_group("player") + tree.get_nodes_in_group("enemies")
		_:
			return[]
			
func use_resources(char_stats: CharacterStats) -> void:
	Events.card_queued.emit(self)
	char_stats.energy -= cost

func undo_use_resources(char_stats: CharacterStats) -> bool:
	var new_energy = char_stats.energy + cost
	var legal_operation = true
	if new_energy < 0:
		legal_operation = false
	if not legal_operation:
		return false
	Events.card_dequeued.emit(self)
	char_stats.energy = new_energy
	return true
	
func play(targets: Array[Node], char_stats: CharacterStats, user: Node) -> void:
	Events.card_played.emit(self)
	
	if is_targeted():
		apply_effects(user, targets)
	else:
		apply_effects(user, _get_targets(targets))

func apply_effects(_user: Node, _targets: Array[Node]) -> void:
	pass
