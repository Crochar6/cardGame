extends Card


func apply_effects(user: Node, targets: Array[Node]) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 1
	damage_effect.execute(targets)
