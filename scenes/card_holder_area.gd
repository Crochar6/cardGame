extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func add_card(card):
	self.add_child(card)
	
	card.position.y = self.get_rect().size.y / 2 - card.size.y/2
	self.position_cards()
	

func position_cards():
	for i in get_children().size():
		var card = get_child(i)
		card.position.x = self.get_rect().size.x / (self.get_child_count()+1) * (i+1) - card.size.x/2
	
	
