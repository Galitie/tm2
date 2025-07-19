extends PanelContainer

signal card_pressed(resource, player)
var chosen_resource : Resource
var upgrade_panel : PlayerUpgradePanel
@onready var accessory_panel = $AccessoryInfo
@onready var card_info_panel = $CardInfo
var accessories  = []

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
	%Stat2.text = chosen_resource.attribute_label_2
	%Stat3.text = chosen_resource.attribute_label_3
	%Amount.text = str(chosen_resource.attribute_amount_1)
	%Amount2.text = str(chosen_resource.attribute_amount_2)
	%Amount3.text = str(chosen_resource.attribute_amount_3)

	if chosen_resource.description:
		%Description.visible = true
	if chosen_resource.attribute_label_1:
		%Stat.visible = true
	if chosen_resource.attribute_amount_1:
		%Amount.visible = true
		%PosNeg.visible = true
		if chosen_resource.attribute_amount_1 > 0:
			%PosNeg.text = "+"
	
	if chosen_resource.attribute_label_2:
		%Stat2.visible = true
	if chosen_resource.attribute_amount_2:
		%Amount2.visible = true
		%PosNeg2.visible = true
		if chosen_resource.attribute_amount_2 > 0:
			%PosNeg2.text = "+"
	
	if chosen_resource.attribute_label_3:
		%Stat3.visible = true
	if chosen_resource.attribute_amount_3:
		%Amount3.visible = true
		%PosNeg3.visible = true
		if chosen_resource.attribute_amount_3 > 0:
			%PosNeg3.text = "+"
	
	if chosen_resource.unique:
		%Tags.text += "UNIQUE"
	#if chosen_resource.state_id: This isn't true for all resources with a state_id
		#if %Tags.text == "":
			#%Tags.text = "SWAP"
		#else:
			#%Tags.text += ", SWAP"
		
	
	for accessory in chosen_resource.accessories:
		var panel = PanelContainer.new()
		var button = Button.new()
		button.icon = accessory.image
		panel.add_child(button)
		$AccessoryInfo/MarginContainer/VBoxContainer/Accessories.add_child(panel)
		accessories.append(panel)

func reset_card():
	%Description.visible = false
	%Stat.visible = false
	%Stat2.visible = false
	%Stat3.visible = false
	%Amount.visible = false
	%Amount2.visible = false
	%Amount3.visible = false
	%PosNeg.visible = false
	%PosNeg2.visible = false
	%PosNeg3.visible = false
	%Tags.text = ""


func disable():
	$CardInfo.disabled = true


func enable():
	$CardInfo.disabled = false
