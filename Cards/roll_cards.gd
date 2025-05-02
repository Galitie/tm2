extends PanelContainer
var max_cards : int = 3
var card = load("uid://dgbiaduauaghx")
signal add_stats_to_mon


func _ready():
	add_cards()


func _process(_delta):
	pass


func add_cards(amount : int = max_cards):
	for cards in range(amount):
		var new_card = build_card()
		%Cards.add_child(new_card)


func remove_cards(amount : int = 1, specific_card : Node = null):
	# remove a number of cards
	if specific_card == null:
		var cards = %Cards.get_children()
		if amount > cards.size():
			amount = cards.size()
		for card in amount:
			cards[card].queue_free()
	else:
		specific_card.queue_free()

# TO-DO, build cards better
func build_card():
	var new_card = card.instantiate()
	new_card.connect("card_pressed", card_pressed)
	return new_card


#TO-DO, make this more flexible...cases where the removal and add are different
func _on_reroll_pressed():
	remove_cards(3)
	add_cards(3)


func card_pressed(card_pressed):
	emit_signal("add_stats_to_mon", card_pressed.info)
	remove_cards(1, card_pressed)
	add_cards(1)
	
