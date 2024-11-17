class_name EnergyUI
extends Panel


@export var char_stats: CharacterStats : set = _set_character_stats
@onready var energy_label: Label = $EnergyLabel
var overcharged = false
var tween: Tween
@onready var init_position = position

func _ready():
	self.pivot_offset = self.get_rect().size/2

func _set_character_stats(value: CharacterStats) -> void:
	char_stats = value
	
	if not char_stats.stats_changed.is_connected(_on_stats_changed):
		char_stats.stats_changed.connect(_on_stats_changed)
	
	if not is_node_ready():
		await ready
	
	_on_stats_changed()

func _on_stats_changed() -> void:
	energy_label.text = "%s/%s" % [char_stats.energy, char_stats.max_energy]
	if char_stats.energy > char_stats.max_energy:
		overcharged = true
		trigger_animation()
	else:
		overcharged= false
		stop_animation()

func trigger_animation():
	if not overcharged:
		return
	var shake_multiplier: float = 0.3 + 0.08*(char_stats.energy - char_stats.max_energy)
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", randi_range(-3, 3)*shake_multiplier, 0.035)
	tween.tween_property(self, "position", self.init_position + Vector2(randi_range(-1, 1)*shake_multiplier, randi_range(-1, 1)*shake_multiplier), 0.035)
	tween.tween_callback(trigger_animation)

func stop_animation():
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "rotation_degrees", 0, 0.5)
	
