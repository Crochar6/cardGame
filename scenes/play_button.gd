extends Node2D


func _on_play_button_pressed():
	Events.play_cards.emit()
