class_name StatsUI
extends VBoxContainer


@onready var sp: HBoxContainer = $SP
@onready var sp_label: Label = %SPLabel
@onready var hp: HBoxContainer = $HP
@onready var hp_label: Label = %HPLabel

func update_stats(stats: Stats) -> void:
	sp_label.text = str(stats.sp)
	hp_label.text = str(stats.hp)
	
