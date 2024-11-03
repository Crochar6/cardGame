extends Area2D

var group_to_check = GlobalDefines.GroupCardDropArea

func _on_area_entered(area):
	if area.get_parent().is_in_group(group_to_check):
		pass
		
func _on_area_exited(area):
	if area.get_parent().is_in_group(group_to_check):
		pass
	
func check_on_interact_area() -> bool:
	for area in self.get_overlapping_areas():
		if area.is_in_group(group_to_check):
			return true
	return false
