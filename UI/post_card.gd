extends Sprite2D

@export var deck_order = 0

signal card_pressed(resource, player, input, button)
var chosen_resource : CardResourceScript
var upgrade_panel : PlayerUpgradePanel
@onready var accessory_panel = $SubViewport/Sprite2D/AccessoryInfo
@onready var accessories = $SubViewport/Sprite2D/AccessoryInfo/MarginContainer/VBoxContainer/Accessories.get_children()
var valid_accessories: Array = []
@onready var accessory_header = $SubViewport/Sprite2D/AccessoryInfo/MarginContainer/VBoxContainer/TitleDescription/Header

enum CardType { COMMON, UNIQUE, SPECIAL }
var type: CardType = CardType.COMMON

@onready var header = $SubViewport/Sprite2D/Header
@onready var description = $SubViewport/Sprite2D/Description
@onready var stats = $SubViewport/Sprite2D/Stats
@onready var banish = $SubViewport/Sprite2D/Banish

@onready var common_texture = load("uid://tsfcfyle4b6g")
@onready var common_backside = load("uid://dfcg1ysqsucr6")
@onready var unique_texture = load("uid://noyaw0jmuiam")
@onready var unique_backside = load("uid://nivlcmg3kc7o")
@onready var special_texture = load("uid://rd37trgsse7k")
@onready var special_backside = load("uid://dj3p7vy3iup0y")

var selected: bool = false
var showing_accessories: bool = false


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
	set_banish_text()
	if upgrade_panel.player.banish_amount:
		banish.visible = true
	
	material.set_shader_parameter("rand_trans_power", 1.0)
	z_index = 3
	selected = true


func deselect() -> void:
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("inset", value), 0.0, 0.4, 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("shadow_offset", value), Vector2(-20.0, -20.0), Vector2(-10.0, -10.0), 0.15)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("blur_amount", value), 1.5, 0.0, 0.15)
	material.set_shader_parameter("rand_trans_power", 0)
	banish.visible = false
	z_index = deck_order
	selected = false


func append_attribute(label, amount) -> void:
	if !label.is_empty():
		if amount > 0:
			stats.text += "{att}+{amt} ".format({"att": label, "amt": amount})
		else:
			stats.text += "{att}{amt} ".format({"att": label, "amt": amount})


func change_text_style() -> void:
	match type:
		CardType.COMMON:
			header.add_theme_color_override("default_color", Color("082d49"))
			header.add_theme_color_override("font_outline_color", Color("bdd4d1"))
			description.add_theme_color_override("default_color", Color("082d49"))
			description.add_theme_color_override("font_outline_color", Color("bdd4d1"))
			stats.add_theme_color_override("default_color", Color("c10711"))
			stats.add_theme_color_override("font_outline_color", Color("bdd4d1"))
			accessory_header.add_theme_color_override("default_color", Color("082d49"))
			accessory_header.add_theme_color_override("font_outline_color", Color("bdd4d1"))
		CardType.UNIQUE:
			header.add_theme_color_override("default_color", Color("3c130a"))
			header.add_theme_color_override("font_outline_color", Color("ecd8bf"))
			description.add_theme_color_override("default_color", Color("3c130a"))
			description.add_theme_color_override("font_outline_color", Color("ecd8bf"))
			stats.add_theme_color_override("default_color", Color("c10711"))
			stats.add_theme_color_override("font_outline_color", Color("ecd8bf"))
			accessory_header.add_theme_color_override("default_color", Color("3c130a"))
			accessory_header.add_theme_color_override("font_outline_color", Color("ecd8bf"))
		CardType.SPECIAL:
			header.add_theme_color_override("default_color", Color("27502f"))
			header.add_theme_color_override("font_outline_color", Color("c7dcba"))
			description.add_theme_color_override("default_color", Color("27502f"))
			description.add_theme_color_override("font_outline_color", Color("c7dcba"))
			stats.add_theme_color_override("default_color", Color("c10711"))
			stats.add_theme_color_override("font_outline_color", Color("c7dcba"))
			accessory_header.add_theme_color_override("default_color", Color("27502f"))
			accessory_header.add_theme_color_override("font_outline_color", Color("c7dcba"))


func set_banish_text():
	banish.text = "[font_size=17]x[/font_size]" + str(upgrade_panel.player.banish_amount) + "[font_size=26]🔥"


func choose_card_resource(card_resource):
	chosen_resource = card_resource
	header.text = chosen_resource.card_name
	
	if selected:
		banish.visible = (upgrade_panel.player.banish_amount > 0)
	
	set_banish_text()
	
	var source_sprite: Sprite2D = $SubViewport/Sprite2D
	if card_resource.is_special:
		type = CardType.SPECIAL
		source_sprite.texture = special_texture
		change_text_style()
	elif card_resource.unique:
		type = CardType.UNIQUE
		source_sprite.texture = unique_texture
		change_text_style()
	else:
		type = CardType.COMMON
		source_sprite.texture = common_texture
		change_text_style()
	
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
	accessory.color = Color.MEDIUM_SPRING_GREEN


func deselect_accessory(accessory: ColorRect) -> void:
	accessory.color = Color.LIGHT_GRAY


func hide_text(toggle: bool) -> void:
	header.visible = !toggle
	description.visible = !toggle
	stats.visible = !toggle


func flip() -> void:
	await get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("y_rot", value), 0.0, 90.0, 0.15).finished
	material.set_shader_parameter("y_rot", -90.0)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("y_rot", value), -90.0, 0.0, 0.15)


func show_accessories() -> void:
	showing_accessories = true
	await get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("y_rot", value), 0.0, 90.0, 0.15).finished
	banish.visible = false
	material.set_shader_parameter("y_rot", -90.0)
	hide_text(true)
	match type:
		CardType.COMMON:
			$SubViewport/Sprite2D.texture = common_backside
		CardType.UNIQUE:
			$SubViewport/Sprite2D.texture = unique_backside
		CardType.SPECIAL:
			$SubViewport/Sprite2D.texture = special_backside
	accessory_panel.visible = true
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("y_rot", value), -90.0, 0.0, 0.15)


func hide_accessories(instant: bool = false) -> void:
	if instant:
		showing_accessories = false
		accessory_panel.visible = false
		if upgrade_panel.player.banish_amount:
			banish.visible = true
		hide_text(false)
		material.set_shader_parameter("y_rot", 0.0)
		return
	
	showing_accessories = false
	await get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("y_rot", value), 0.0, 90.0, 0.15).finished
	match type:
		CardType.COMMON:
			$SubViewport/Sprite2D.texture = common_texture
		CardType.UNIQUE:
			$SubViewport/Sprite2D.texture = unique_texture
		CardType.SPECIAL:
			$SubViewport/Sprite2D.texture = special_texture
	material.set_shader_parameter("y_rot", -90.0)
	accessory_panel.visible = false
	if upgrade_panel.player.banish_amount:
		banish.visible = true
	hide_text(false)
	get_tree().create_tween().tween_method(func(value): material.set_shader_parameter("y_rot", value), -90.0, 0.0, 0.15)


func disabled() -> bool:
	return false
