extends Card


func apply_effects(user: Node, targets: Array[Node]) -> void:
	
	var set_shield_effect := SetShieldEffect.new()
	set_shield_effect.amount = 0
	set_shield_effect.execute([user])
	
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 4
	damage_effect.execute(targets)
