class_name Stats
extends Resource

signal stats_changed

@export var max_hp := 1
@export var max_sp := 1
@export var art: Texture

var hp: int : set = set_hp
var sp: int : set = set_sp

func set_hp(value: int) -> void:
	hp = clampi(value, 0, max_hp)
	stats_changed.emit()

func set_sp(value: int) -> void:
	sp = clampi(value, 0, max_sp)
	stats_changed.emit()

func take_damage(damage: int) -> void:
	if damage <= 0:
		return
	var initial_damage = damage
	damage = clampi(damage - sp, 0, damage)
	self.sp = clampi(sp - initial_damage, 0, sp)
	self.hp -= damage
	
	var dead := false
	if hp <=0:
		dead

func repair_hull(amount: int) -> void:
	self.hp = clampi(hp + amount, 0, max_hp)

func repair_shield(amount: int) -> void:
	self.sp = clampi(sp + amount, 0, max_sp)

func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance.hp = max_hp
	instance.sp = max_sp
	return instance
