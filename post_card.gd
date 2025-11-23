extends Sprite2D

@export var deck_order = 0

signal card_pressed(resource, player, input, button)
var chosen_resource : CardResourceScript
var upgrade_panel : PlayerUpgradePanel
@onready var accessory_panel = $SubViewport/Sprite2D/AccessoryInfo
#@onready var card_info_panel = $CardInfo
@onready var accessories = $SubViewport/Sprite2D/AccessoryInfo/MarginContainer/VBoxContainer/Accessories.get_children()
var valid_accessories: Array = []
@onready var accessory_header = $SubViewport/Sprite2D/AccessoryInfo/MarginContainer/VBoxContainer/TitleDescription/Header
#@onready var x_texture = load("res://none_icon.png")

@onready var header = $SubViewport/Sprite2D/Header
@onready var description = $SubViewport/Sprite2D/Description
@onready var stats = $SubViewport/Sprite2D/Stats

@onready var common_texture = load("uid://tsfcfyle4b6g")
@onready var unique_texture = load("uid://noyaw0jmuiam")
@onready var special_texture = load("uid://rd37trgsse7k")

var selected: bool = false

func _ready() -> void:
	material.set_shader_parameter("inset", 0.4)
	material.set_shader_parameter("color", Color("0000006e"))
	material.set_shader_parameter("position", Vector2(0.5, 0.5))
	material.set_shader_parameter("borderWidth", 0.01)
	material.set_shader_parameter("burnColor", Color("ed4104"))
	var noise_texture: NoiseTexture2D = NoiseTexture2D.new()
	noise_texture.width = 1024
	noise_texture.height = 1024
	var fast_noise: FastNoiseLite = FastNoiseLite.new()
	fast_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise_texture.noise = fast_noise
	material.set_shader_parameter("noiseTexture", noise_texture)
	
	z_index = deck_order

func _on_button_pressed(acc_index : int = 0, input = null, button = null):
	emit_signal("card_pressed", self, acc_index, input, button) # Caught by game scene
	
func burn_vfx() -> void:
	await get_tree().create_tween().tween_method(set_radius, 0.0, 1.0, 1.0).finished
	await get_tree().create_tween().tween_method(set_radius, 1.0, 0.0, 0.0).finished
	
func set_radius(radius: float) -> void:
	material.set_shader_parameter("radius", radius)
	
func is_unique() -> bool:
	return chosen_resource.unique
	
func select() -> void:
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("inset", value), 0.4, 0.0, 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("shadow_offset", value), Vector2(-10.0, -10.0), Vector2(-20.0, -20.0), 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("blur_amount", value), 0.0, 1.5, 0.15)
	material.set_shader_parameter("rand_trans_power", 1.0)
	z_index = 3
	selected = true
	
func deselect() -> void:
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("inset", value), 0.0, 0.4, 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("shadow_offset", value), Vector2(-20.0, -20.0), Vector2(-10.0, -10.0), 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("blur_amount", value), 1.5, 0.0, 0.15)
	material.set_shader_parameter("rand_trans_power", 0)
	z_index = deck_order
	selected = false

func append_attribute(label, amount) -> void:
	if !label.is_empty():
		if amount > 0:
			stats.text += "{att}+{amt} ".format({"att": label, "amt": amount})
		else:
			stats.text += "{att}{amt} ".format({"att": label, "amt": amount})

enum CardStyle { COMMON, UNIQUE, SPECIAL }

func change_text_style(style: CardStyle) -> void:
	match style:
		CardStyle.COMMON:
			header.add_theme_color_override("default_color", Color("082d49"))
			header.add_theme_color_override("font_outline_color", Color("bdd4d1"))
			description.add_theme_color_override("default_color", Color("082d49"))
			description.add_theme_color_override("font_outline_color", Color("bdd4d1"))
			stats.add_theme_color_override("default_color", Color("082d49"))
			stats.add_theme_color_override("font_outline_color", Color("bdd4d1"))
			accessory_header.add_theme_color_override("default_color", Color("082d49"))
			accessory_header.add_theme_color_override("font_outline_color", Color("bdd4d1"))
		CardStyle.UNIQUE:
			header.add_theme_color_override("default_color", Color("3c130a"))
			header.add_theme_color_override("font_outline_color", Color("ecd8bf"))
			description.add_theme_color_override("default_color", Color("3c130a"))
			description.add_theme_color_override("font_outline_color", Color("ecd8bf"))
			stats.add_theme_color_override("default_color", Color("3c130a"))
			stats.add_theme_color_override("font_outline_color", Color("ecd8bf"))
			accessory_header.add_theme_color_override("default_color", Color("3c130a"))
			accessory_header.add_theme_color_override("font_outline_color", Color("ecd8bf"))
		CardStyle.SPECIAL:
			header.add_theme_color_override("default_color", Color("27502f"))
			header.add_theme_color_override("font_outline_color", Color("c7dcba"))
			description.add_theme_color_override("default_color", Color("27502f"))
			description.add_theme_color_override("font_outline_color", Color("c7dcba"))
			stats.add_theme_color_override("default_color", Color("27502f"))
			stats.add_theme_color_override("font_outline_color", Color("c7dcba"))
			accessory_header.add_theme_color_override("default_color", Color("27502f"))
			accessory_header.add_theme_color_override("font_outline_color", Color("c7dcba"))

func choose_card_resource(card_resource):
	chosen_resource = card_resource
	header.text = chosen_resource.card_name
	
	var source_sprite: Sprite2D = $SubViewport/Sprite2D
	if card_resource.unique:
		source_sprite.texture = unique_texture
		change_text_style(CardStyle.UNIQUE)
	elif card_resource.is_special:
		source_sprite.texture = special_texture
		change_text_style(CardStyle.SPECIAL)
	else:
		source_sprite.texture = common_texture
		change_text_style(CardStyle.COMMON)
	
	var description_words: PackedStringArray = chosen_resource.description.split(' ')
	for i in range(description_words.size()):
		if description_words[i] == description_words[i].to_upper():
			description_words[i] = "[color=C10711]{word}[/color]".format({"word":description_words[i]})
	description.text = " ".join(description_words)
	
	stats.text = ""
	append_attribute(chosen_resource.attribute_label_1, chosen_resource.attribute_amount_1)
	append_attribute(chosen_resource.attribute_label_2, chosen_resource.attribute_amount_2)
	append_attribute(chosen_resource.attribute_label_3, chosen_resource.attribute_amount_3)
	
	valid_accessories.clear()
	if chosen_resource.parts_and_acc.size():
		for i in range(accessories.size()):
			var acc: ColorRect = accessories[i]
			if i < chosen_resource.parts_and_acc.size():
				acc.visible = true
				acc.get_node("TextureRect").texture = chosen_resource.parts_and_acc[i].texture
				valid_accessories.append(acc)
			else:
				acc.visible = false
		accessories[accessories.size() - 1].visible = true
		valid_accessories.append(accessories[accessories.size() - 1])

func select_accessory(accessory: ColorRect) -> void:
	accessory.color = Color.DODGER_BLUE
	
func deselect_accessory(accessory: ColorRect) -> void:
	accessory.color = Color.TRANSPARENT

func hide_text(toggle: bool) -> void:
	header.visible = !toggle
	description.visible = !toggle
	stats.visible = !toggle
	
func show_accessories() -> void:
	hide_text(true)
	accessory_panel.visible = true
	
func hide_accessories() -> void:
	accessory_panel.visible = false
	hide_text(false)
	
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
