extends PanelContainer

signal card_pressed(resource, player)
var chosen_resource : Resource
var upgrade_panel : PlayerUpgradePanel


func _process(_delta):
	pass


func _on_button_pressed():
	emit_signal("card_pressed", self) #Caught by game scene


func choose_card_resource(card_resource):
	reset_card()
	chosen_resource = card_resource
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
