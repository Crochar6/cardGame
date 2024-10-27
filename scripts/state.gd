class_name State
extends Node

var parent: Card

func enter():
	pass
	
func exit():
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
