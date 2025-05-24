extends PanelContainer

signal card_pressed(resource, player)
var resource_array: Array[Resource] = [load("uid://c37d7vyo0m6jb"), load("uid://3aquqn25lskq"), load("uid://cvtqvsltnme3w")]
var chosen_resource : Resource
var upgrade_panel : PlayerUpgradePanel

func _ready():
	choose_card_resource()


func _process(_delta):
	pass


func _on_button_pressed():
	emit_signal("card_pressed", self) #Caught by game scene


func choose_card_resource():
	reset_card()
	chosen_resource = resource_array.pick_random()
	if chosen_resource.limited_to_one:
		print("can only have one")
		# The card creation needs to consider if the monster already has that ability and the card is limited to one.
		# If the monster already has it, it needs to pick a different one.
		# Monster keeps it's list of states in state machine
		# May also have to just consider 1 time offers that aren't stored as a state?
	%Title.text = chosen_resource.card_name
	%Description.text = chosen_resource.description
	%Stat.text = chosen_resource.attribute_label_1
	%Amount.text = str(chosen_resource.attribute_amount_1)

	if chosen_resource.description:
		%Description.visible = true
	if chosen_resource.attribute_label_1:
		%Stat.visible = true
	if chosen_resource.attribute_amount_1:
		%Amount.visible = true
		%PosNeg.visible = true
		if chosen_resource.attribute_amount_1 > 0:
			%PosNeg.text = "+"
		else:
			%PosNeg.text = "-"


func reset_card():
	%Description.visible = false
	%Stat.visible = false
	%Amount.visible = false
	%PosNeg.visible = false


func disable():
	$Button.disabled = true


func enable():
	$Button.disabled = false
