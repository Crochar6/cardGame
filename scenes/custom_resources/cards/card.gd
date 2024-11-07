class_name Card
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

@export_category("Card Attributes")
@export var id: String
@export var target: Target
@export var rarity: Rarity
@export var cost: int
@export var art: Texture2D


func is_single_targeted() -> bool:
	return self.target == Target.SINGLE_ENEMY
