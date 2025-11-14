extends MarginContainer
class_name PlayerUpgradePanel

signal reroll_pressed(upgrade_panel)

@onready var reroll_button : Button = $VBoxContainer/HBoxContainer/Reroll
@onready var upgrade_cards = [$VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3 ]
@onready var upgrade_title = $VBoxContainer/UpgradeTitle/Label

var player : Player
var resource_array: Array[Resource] = [load("uid://fk8ruy5a3i6t"),load("uid://ypvgbouvw3wv"),load("uid://f53own34678k"),load("uid://beo0p0kljyb5g"), load("uid://0fnohogd0jnj"), load("uid://4pdhr1tis8vw"), load("uid://cn4ovy3i6wd8s"), load("uid://bnduresmutm6t"), load("uid://cjql6et6c05ls"), load("uid://n6000538073l"), load("uid://cgypuyq157lm6"), load("uid://phcwpn7m4yun"), load("res://Cards/Resources/thorns.tres"), load("uid://x788fm7x6b4i"), load("uid://bd56nejnv5k61"), load("uid://dowb4h6fynu1t"), load("uid://d38rynb3vrmjg"), load("uid://d1mv22yolom78"), load("uid://2dwrrigu8sux"), load("uid://b1yf5pmgknoky"), load("uid://bn1d6phtvfhry"),load("uid://bkgtuu1m8soho"),load("uid://dyvymb65crfuv"),load("uid://c37d7vyo0m6jb"), load("uid://3aquqn25lskq"), load("uid://cvtqvsltnme3w"), load("uid://cv4dcuvdmk4d"), load("uid://cr0ughlj0g43p"), load("uid://c6dyyjnj08tgh"), load("uid://ds51dyaoyuqjg"), load("uid://b7mqshabtd6un"), load("uid://d4m0ycr7geqti")]
@onready var button_array: Array[Node] = [reroll_button, $VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3]
var current_user_position_in_button_array : int = 0
var new_stylebox_normal = StyleBoxFlat.new()

var current_user_position_in_accessory_array : int = 0
var in_accessory_menu = false

var input_paused: bool = false

var stamp_sfx = load("uid://o81tlwdlwbgw")
var fire_sfx = load("uid://cqg3cxtk5uaua")

func _ready():
	for card in upgrade_cards:
		card.upgrade_panel = self
	create_stylebox()


func press_card(button, acc_idx: int = 0, input = null) -> void:
	input_paused = true
	if input == JOY_BUTTON_A:
		input_paused = true
		%Stamp.visible = true
		%Stamp.global_position = button.global_position + button.size * 0.5
		%Stamp.scale = Vector2(2.0, 2.0)
		await get_tree().create_tween().tween_property(%Stamp, "scale", Vector2(1.0, 1.0), 0.1).finished
		get_tree().create_tween().tween_property(%Stamp, "visible", false, 1.0)
		%AudioStreamPlayer.stream = stamp_sfx
		%AudioStreamPlayer.play()
		
		if button.is_unique():
			await %AudioStreamPlayer.finished
			%AudioStreamPlayer.stream = fire_sfx
			%AudioStreamPlayer.play()
			button.burn_vfx()
			await get_tree().create_timer(1.0).timeout
		else:
			await get_tree().create_timer(0.5).timeout
	input_paused = false
	button._on_button_pressed(acc_idx, input, button)



func burn_card(button):
	input_paused = true
	%AudioStreamPlayer.stream = fire_sfx
	%AudioStreamPlayer.play()
	button.burn_vfx()
	await get_tree().create_timer(1.0).timeout
	input_paused = false


func _physics_process(_delta):
	if input_paused:
		return
	
	if player.upgrade_points > 0:
		if current_user_position_in_button_array == 0:
			reroll_button.add_theme_stylebox_override("normal", new_stylebox_normal)
			reroll_button.add_theme_stylebox_override("disabled", new_stylebox_normal)
		var dpad_vertical_input: int =  Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_DOWN) - Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_UP)
		var dpad_horizontal_input: int =  Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_RIGHT) - Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_LEFT)
		
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_DOWN) || Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_UP):
			current_user_position_in_button_array += dpad_vertical_input
			if current_user_position_in_button_array <= -1:
				current_user_position_in_button_array = button_array.size() - 1
			if current_user_position_in_button_array >= button_array.size():
				current_user_position_in_button_array = 0
			# Really shitty way to see what index player is on
			var button = button_array[current_user_position_in_button_array]
			if button == reroll_button:
				reroll_button.add_theme_stylebox_override("normal", new_stylebox_normal)
			else:
				button.add_theme_stylebox_override("panel", new_stylebox_normal)
				reroll_button.remove_theme_stylebox_override("normal")
				reroll_button.remove_theme_stylebox_override("disabled")
			for other_button in button_array:
				if other_button != reroll_button:
					other_button.card_info_panel.show()
					other_button.accessory_panel.hide()
				if other_button != button:
					other_button.remove_theme_stylebox_override("panel")
			in_accessory_menu = false
		
		# To banish cards
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_Y) and !in_accessory_menu:
			var button = button_array[current_user_position_in_button_array]
			var input = JOY_BUTTON_Y
			if button != reroll_button:
				press_card(button, 0, input)
			
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_A):
			var button = button_array[current_user_position_in_button_array]
			var input = JOY_BUTTON_A
			if button == reroll_button:
				_on_button_pressed()
			else:
				# For navigating the accessory menu
				if button.chosen_resource.parts_and_acc.size() > 0:
					if in_accessory_menu:
						# already in the acc menu and pressed something
						in_accessory_menu = false
						
						press_card(button, current_user_position_in_accessory_array, input)
						button.card_info_panel.show()
						button.accessory_panel.hide()
					else:
						#Not yet in the acc menu, but will enter it now
						button.card_info_panel.hide()
						button.accessory_panel.show()
						current_user_position_in_accessory_array = 0
						var accessory_button = button.accessories[current_user_position_in_accessory_array]
						accessory_button.add_theme_stylebox_override("panel", new_stylebox_normal)
						in_accessory_menu = true
						for other_button in button.accessories:
							if other_button != accessory_button:
								other_button.remove_theme_stylebox_override("panel")
				else:
					press_card(button, 0, input)
		
		var button = button_array[current_user_position_in_button_array]
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_B) and button != reroll_button and button.accessory_panel.visible:
			button.card_info_panel.show()
			button.accessory_panel.hide()
			in_accessory_menu = false
		
		# For navigating the accessory menu
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_LEFT) and button != reroll_button || Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_RIGHT) and button != reroll_button:
			if button.accessory_panel.visible:
				current_user_position_in_accessory_array += dpad_horizontal_input
				if current_user_position_in_accessory_array <= -1:
					current_user_position_in_accessory_array = button.accessories.size() - 1
				if current_user_position_in_accessory_array >= button.accessories.size():
					current_user_position_in_accessory_array = 0
				var accessory_button = button.accessories[current_user_position_in_accessory_array]
				accessory_button.add_theme_stylebox_override("panel", new_stylebox_normal)
				for other_button in button.accessories:
					if other_button != accessory_button:
						other_button.remove_theme_stylebox_override("panel")
	else:
		var button = button_array[current_user_position_in_button_array]
		if button == reroll_button:
			reroll_button.remove_theme_stylebox_override("normal")
			reroll_button.remove_theme_stylebox_override("disabled")
		else:
			button.remove_theme_stylebox_override("panel")


func disable_cards():
	for card in upgrade_cards:
		card.disable()
		card.hide()


func setup_cards():
	current_user_position_in_button_array = 0
	var temp_resources = resource_array.duplicate(true)
	for card in upgrade_cards:
		card.show()
		var random_resource = temp_resources.pick_random()
		if random_resource.unique:
			temp_resources.erase(random_resource)
		card.choose_card_resource(random_resource)
		card.enable()


func update_victory_points():
	$VBoxContainer/DudeWindow/VBoxContainer/Victory.text = "👑 " + str(player.victory_points)


func setup_rerolls():
	var bonus_text = ""
	if player.bonus_rerolls > 0:
		pass
		#bonus_text = " Includes Bonus"
	if player.rerolls > 0:
		reroll_button.text = "🎲 ALL " + "[x" + str(player.rerolls) + "]" + bonus_text
		reroll_button.disabled = false
	else:
		reroll_button.text = "NO 🎲 LEFT"
		reroll_button.disabled = true

# reroll button
func _on_button_pressed():
	emit_signal("reroll_pressed", self) #Caught by game scene


func create_stylebox():
	new_stylebox_normal.border_width_top = 5
	new_stylebox_normal.border_width_bottom = 5
	new_stylebox_normal.border_width_left = 5
	new_stylebox_normal.border_width_right = 5
	new_stylebox_normal.border_color = Color.SKY_BLUE


func remove_from_card_pool(resource):
	var found_index = resource_array.find(resource)
	resource_array.remove_at(found_index)


func update_banish_text():
	if player.banish_amount > 0:
		%Banish.text = "🔥" + " BANISH " + "[x" + str(player.banish_amount) + "]"
	else:
		%Banish.add_theme_color_override("font_color", Color(1,1,1,.5))
		%Banish.text = "NO 🔥 LEFT"

func update_place_text(player):
	if player.place == 1:
		$VBoxContainer/DudeWindow/VBoxContainer/Place.text = "🏆 " + str(player.place) + "st"
	elif player.place == 2:
		$VBoxContainer/DudeWindow/VBoxContainer/Place.text = "🏆 " + str(player.place) + "nd"
	elif player.place == 3:
		$VBoxContainer/DudeWindow/VBoxContainer/Place.text = "🏆 " + str(player.place) + "rd"
	elif player.place == 4:
		$VBoxContainer/DudeWindow/VBoxContainer/Place.text = "🏆 " + str(player.place) + "th"
