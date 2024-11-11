extends Card


func apply_effects(targets: Array[Node]) -> void:
	var add_shield_effect := AddShieldEffect.new()
	add_shield_effect.amount = 1
	add_shield_effect.execute(targets)
