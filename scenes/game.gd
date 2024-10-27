extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var card_scene: PackedScene = load("res://scenes/cards/card.tscn")
	
	for i in range(6):
		var card = card_scene.instantiate()
		$HandArea.add_card(card)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
