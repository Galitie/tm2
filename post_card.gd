extends Sprite2D

@export var deck_order = 0

signal card_pressed(resource, player, input, button)
var chosen_resource : CardResourceScript
var upgrade_panel : PlayerUpgradePanel
#@onready var accessory_panel = $AccessoryInfo
#@onready var card_info_panel = $CardInfo
var accessories  = []
#@onready var x_texture = load("res://none_icon.png")

@onready var header = $SubViewport/Sprite2D/Header
@onready var description = $SubViewport/Sprite2D/Description
@onready var stats = $SubViewport/Sprite2D/Stats

func _ready() -> void:
	material.set_shader_parameter("inset", 0.4)
	material.set_shader_parameter("color", Color("0000006e"))
	z_index = deck_order

func _on_button_pressed(acc_index : int = 0, input = null, button = null):
	emit_signal("card_pressed", self, acc_index, input, button) # Caught by game scene
	
func burn_vfx() -> void:
	pass
	#hide_text()
	#await get_tree().create_tween().tween_method(set_radius, 0.0, 1.0, 1.0).finished
	#await get_tree().create_tween().tween_method(set_radius, 1.0, 0.0, 0.0).finished
	
#func set_radius(radius: float) -> void:
	#material.set_shader_parameter("radius", radius)
	
func is_unique() -> bool:
	return chosen_resource.unique
	
func select() -> void:
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("inset", value), 0.4, 0.0, 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("shadow_offset", value), Vector2(-10.0, -10.0), Vector2(-20.0, -20.0), 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("blur_amount", value), 0.0, 1.5, 0.15)
	material.set_shader_parameter("rand_trans_power", 1.0)
	z_index = 0
	
func deselect() -> void:
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("inset", value), 0.0, 0.4, 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("shadow_offset", value), Vector2(-20.0, -20.0), Vector2(-10.0, -10.0), 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("blur_amount", value), 1.5, 0.0, 0.15)
	material.set_shader_parameter("rand_trans_power", 0)
	z_index = deck_order

func append_attribute(label, amount) -> void:
	if !label.is_empty():
		if amount > 0:
			stats.text += "{att}+{amt} ".format({"att": label, "amt": amount})
		else:
			stats.text += "{att}{amt} ".format({"att": label, "amt": amount})

func choose_card_resource(card_resource):
	chosen_resource = card_resource
	header.text = chosen_resource.card_name
	
	var description_words: PackedStringArray = chosen_resource.description.split(' ')
	for i in range(description_words.size()):
		if description_words[i] == description_words[i].to_upper():
			description_words[i] = "[color=C10711]{word}[/color]".format({"word":description_words[i]})
	description.text = " ".join(description_words)
	
	stats.text = ""
	append_attribute(chosen_resource.attribute_label_1, chosen_resource.attribute_amount_1)
	append_attribute(chosen_resource.attribute_label_2, chosen_resource.attribute_amount_2)
	append_attribute(chosen_resource.attribute_label_3, chosen_resource.attribute_amount_3)

	#reset_card()
	#%Title.visible = true
	#chosen_resource = card_resource
	#%Title.text = chosen_resource.card_name
	#%Description.text = chosen_resource.description
	#%Stat.text = chosen_resource.attribute_label_1
	#%Stat2.text = chosen_resource.attribute_label_2
	#%Stat3.text = chosen_resource.attribute_label_3
	#%Amount.text = str(chosen_resource.attribute_amount_1)
	#%Amount2.text = str(chosen_resource.attribute_amount_2)
	#%Amount3.text = str(chosen_resource.attribute_amount_3)

	#if chosen_resource.description:
		#%Description.visible = true
	#
	#if chosen_resource.attribute_label_1:
		#%Stat.visible = true
	#if chosen_resource.attribute_amount_1:
		#%Amount.text = str(abs(int(%Amount.text)))
		#%Amount.visible = true
		#%PosNeg.visible = true
		#if chosen_resource.attribute_amount_1 > 0:
			#%PosNeg.text = "+"
		#else:
			#%PosNeg.text = "-"
	#
	#if chosen_resource.attribute_label_2:
		#%Stat2.visible = true
	#if chosen_resource.attribute_amount_2:
		#%Amount2.text = str(abs(int(%Amount2.text)))
		#%Amount2.visible = true
		#%PosNeg2.visible = true
		#if chosen_resource.attribute_amount_2 > 0:
			#%PosNeg2.text = "+"
		#else:
			#%PosNeg2.text = "-"
	#
	#if chosen_resource.attribute_label_3:
		#%Stat3.visible = true
	#if chosen_resource.attribute_amount_3:
		#%Amount3.text = str(abs(float(%Amount3.text)))
		#%Amount3.visible = true
		#%PosNeg3.visible = true
		#if chosen_resource.attribute_amount_3 > 0:
			#%PosNeg3.text = "+"
		#else:
			#%PosNeg3.text = "-"
	#
	#if chosen_resource.unique:
		#%Tags.text += "UNIQUE 🌟 "
	
	#if chosen_resource.parts_and_acc.size():
		#%Tags.text += "ACC 🎩"
		#for accessory : MonsterPart in chosen_resource.parts_and_acc:
			#make_acc_button(accessory.texture)
		#make_acc_button(x_texture)

func hide_text() -> void:
	header.visible = false
	description.visible = false
	stats.visible = false
	#%Title.visible = false
	#%Description.visible = false
	#%Stat.visible = false
	#%Stat2.visible = false
	#%Stat3.visible = false
	#%Amount.visible = false
	#%Amount2.visible = false
	#%Amount3.visible = false
	#%PosNeg.visible = false
	#%PosNeg2.visible = false
	#%PosNeg3.visible = false
	#%Tags.text = ""
	
func disabled() -> bool:
	return false
	#return card_info_panel.disabled

func reset_card():
	pass
	#hide_text()
	#%Title.visible = true
	#%Tags.text = ""
	#accessories = []
	#var accessories_panel = $AccessoryInfo/MarginContainer/VBoxContainer/Accessories
	#for panel in accessories_panel.get_children():
		#panel.queue_free()
	
func disable():
	pass
	#$CardInfo.disabled = true

func enable():
	pass
	#$CardInfo.disabled = false

func make_acc_button(texture : Texture2D):
	pass
	#var panel = PanelContainer.new()
	#var button = Button.new()
	#button.icon = texture
	#button.expand_icon = true
	#button.custom_minimum_size = Vector2(50,50)
	#button.size = Vector2(50,50)
	#panel.add_child(button)
	#$AccessoryInfo/MarginContainer/VBoxContainer/Accessories.add_child(panel)
	#accessories.append(panel)	
