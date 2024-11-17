class_name StatsUI
extends VBoxContainer


@onready var sp: HBoxContainer = $SP
@onready var sp_label: Label = %SPLabel
@onready var hp: HBoxContainer = $HP
@onready var hp_label: Label = %HPLabel
var stats: Stats
var tween: Tween

func update_stats(stats: Stats) -> void:
	self.stats = stats
	sp_label.text = "%s/%s" % [stats.sp, stats.max_sp]
	hp_label.text = "%s/%s" % [stats.hp, stats.max_hp]
	
	if not stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.connect(_on_stats_changed)
	

func _on_stats_changed():
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if stats.sp <= 0:
		tween.tween_property(sp, "modulate:a", 0.4, 0.15)
	else:
		tween.tween_property(sp, "modulate:a", 1, 1)
	
