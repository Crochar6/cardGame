class_name Card
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

@export_category("Card Attributes")
@export var id: String
@export var target: Target
@export var rarity: Rarity
@export var cost: int
@export_multiline var tooltip: String

@export_category("Card Visuals")
@export var art: Texture2D


func is_single_targeted() -> bool:
	return self.target == Target.SINGLE_ENEMY

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
	Events.card_dequeued.emit(self)
	char_stats.energy -= cost

func undo_use_resources(char_stats: CharacterStats) -> void:
	Events.card_queued.emit(self)
	char_stats.energy += cost
	
func play(targets: Array[Node], char_stats: CharacterStats) -> void:
	Events.card_played.emit(self)
	
	if is_single_targeted():
		apply_effects(targets)
	else:
		apply_effects(_get_targets(targets))

func apply_effects(_targets: Array[Node]) -> void:
	pass
