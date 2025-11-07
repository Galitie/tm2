extends PanelContainer

signal card_pressed(resource, player)
var chosen_resource : Resource
var upgrade_panel : PlayerUpgradePanel
@onready var accessory_panel = $AccessoryInfo
@onready var card_info_panel = $CardInfo
var accessories  = []
@onready var x_texture = load("res://none_icon.png")

func _process(_delta):
	pass


func _on_button_pressed(acc_index : int = 0):
	hide_text()
	await get_tree().create_tween().tween_method(set_radius, 0.0, 1.0, 1.0).finished
	emit_signal("card_pressed", self, acc_index) #Caught by game scene
	await get_tree().create_tween().tween_method(set_radius, 1.0, 0.0, 0.0).finished
	
func set_radius(radius: float) -> void:
	material.set_shader_parameter("radius", radius)

func choose_card_resource(card_resource):
	reset_card()
	%Title.visible = true
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
		%Tags.text += "UNIQUE 🌟 "
	
	if chosen_resource.parts_and_acc.size():
		%Tags.text += "ACC 🎩"
		for accessory : MonsterPart in chosen_resource.parts_and_acc:
			make_acc_button(accessory.texture)
		make_acc_button(x_texture)

func hide_text() -> void:
	%Title.visible = false
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
	
func disabled() -> bool:
	return card_info_panel.disabled

func reset_card():
	hide_text()
	%Title.visible = true
	%Tags.text = ""
	accessories = []
	var accessories_panel = $AccessoryInfo/MarginContainer/VBoxContainer/Accessories
	for panel in accessories_panel.get_children():
		panel.queue_free()
	
func disable():
	$CardInfo.disabled = true

func enable():
	$CardInfo.disabled = false

func make_acc_button(texture : Texture2D):
		var panel = PanelContainer.new()
		var button = Button.new()
		button.icon = texture
		button.expand_icon = true
		button.custom_minimum_size = Vector2(50,50)
		button.size = Vector2(50,50)
		panel.add_child(button)
		$AccessoryInfo/MarginContainer/VBoxContainer/Accessories.add_child(panel)
		accessories.append(panel)	
