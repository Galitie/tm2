extends MarginContainer
class_name PlayerUpgradePanel

signal reroll_pressed(upgrade_panel)

@onready var reroll_button = $VBoxContainer/reroll
@onready var upgrade_cards = [$VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3 ]
@onready var upgrade_title = $VBoxContainer/UpgradeTitle/Label

var player : Player
var resource_array: Array[Resource] = [load("uid://dffb24h22tnbi"), load("uid://bsvu0x8037yil"),load("uid://dbvivyf8n66v3"),load("uid://fk8ruy5a3i6t"),load("uid://ypvgbouvw3wv"),load("uid://f53own34678k"),load("uid://beo0p0kljyb5g"), load("uid://0fnohogd0jnj"), load("uid://bnduresmutm6t"), load("uid://cjql6et6c05ls"), load("uid://n6000538073l"), load("uid://cgypuyq157lm6"), load("uid://phcwpn7m4yun"), load("uid://cgnshcx2dt16q"), load("uid://bd56nejnv5k61"), load("uid://dowb4h6fynu1t"), load("uid://d38rynb3vrmjg"), load("uid://2dwrrigu8sux"), load("uid://bn1d6phtvfhry"),load("uid://bkgtuu1m8soho"),load("uid://dyvymb65crfuv"),load("uid://c37d7vyo0m6jb"), load("uid://3aquqn25lskq"), load("uid://cvtqvsltnme3w"), load("uid://cv4dcuvdmk4d"), load("uid://cr0ughlj0g43p"), load("uid://c6dyyjnj08tgh"), load("uid://ds51dyaoyuqjg"), load("uid://b7mqshabtd6un"), load("uid://d4m0ycr7geqti")]
@onready var button_array: Array[Node] = [reroll_button, $VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3]
var current_user_position_in_button_array : int = 0
var new_stylebox_normal = StyleBoxFlat.new()

var current_user_position_in_accessory_array : int = 0
var in_accessory_menu = false

var input_paused: bool = false

var stamp_sfx = load("uid://o81tlwdlwbgw")
var fire_sfx = load("uid://cqg3cxtk5uaua")
var dice_sfx = load("uid://c00bd21trfdkx")

func _ready():
	for card in upgrade_cards:
		card.upgrade_panel = self
	create_stylebox()
	
	await get_tree().physics_frame
	if player.player_state == player.PlayerState.BOT:
		reroll_button.visible = false


func press_card(button, acc_idx: int = 0, input = null) -> void:
	input_paused = true
	if input == JOY_BUTTON_A and player.player_state != Player.PlayerState.BOT:
		input_paused = true
		%Stamp.visible = true
		%Stamp.global_position = button.global_position
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
	if button.showing_accessories:
		button.hide_accessories(true)
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
		
	# make sure bunnies are back in their spot
	if player.upgrade_points > 0 and player.monster.global_position == player.monster.target_point and Globals.game.current_mode == Globals.game.Modes.UPGRADE:
		#handle bots
		if player.player_state == player.PlayerState.BOT:
			input_paused = true
			var button = button_array[1]
			await get_tree().create_timer(1).timeout
			press_card(button, 1, JOY_BUTTON_A)
			input_paused = false
			return
		
		if current_user_position_in_button_array == 0:
			select_reroll()
			
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
				select_reroll()
			else:
				button.select()
				
			for other_button in button_array:
				if other_button != button:
					if other_button == reroll_button:
						deselect_reroll()
					else:
						if other_button.selected:
							other_button.deselect()
						if other_button.showing_accessories:
							other_button.hide_accessories()
		
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
					else:
						button.show_accessories()
						current_user_position_in_accessory_array = 0
						var accessory_button = button.valid_accessories[current_user_position_in_accessory_array]
						button.select_accessory(accessory_button)
						in_accessory_menu = true
						for other_button in button.valid_accessories:
							if other_button != accessory_button:
								button.deselect_accessory(other_button)
				else:
					press_card(button, 0, input)
		
		var button = button_array[current_user_position_in_button_array]
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_B) and button != reroll_button and button.accessory_panel.visible:
			button.hide_accessories()
			in_accessory_menu = false
		
		# For navigating the accessory menu
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_LEFT) and button != reroll_button || Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_RIGHT) and button != reroll_button:
			if button.accessory_panel.visible:
				current_user_position_in_accessory_array += dpad_horizontal_input
				if current_user_position_in_accessory_array < 0:
					current_user_position_in_accessory_array = button.valid_accessories.size() - 1
				if current_user_position_in_accessory_array > button.valid_accessories.size() - 1:
					current_user_position_in_accessory_array = 0
				var accessory_button = button.valid_accessories[current_user_position_in_accessory_array]
				button.select_accessory(accessory_button)
				for other_button in button.valid_accessories:
					if other_button != accessory_button:
						button.deselect_accessory(other_button)
	else:
		var button = button_array[current_user_position_in_button_array]
		if button == reroll_button:
			deselect_reroll()
		else:
			button.deselect()


func disable_cards():
	for card in upgrade_cards:
		card.disable()
		card.hide()

func select_reroll() -> void:
	get_tree().create_tween().tween_property(reroll_button, "scale", Vector2(1.3, 1.3), 0.15)
	if player.rerolls > 0:
		reroll_button.play("active")
	else:
		reroll_button.play("off")
	
func deselect_reroll() -> void:
	get_tree().create_tween().tween_property(reroll_button, "scale", Vector2(1.0, 1.0), 0.15)
	if player.rerolls > 0:
		reroll_button.play("done")
	else:
		reroll_button.play("off")

func setup_cards(reroll = false):
	current_user_position_in_button_array = 0
	var temp_resources = resource_array.duplicate(true)
	for card in upgrade_cards:
		if player.player_state == Player.PlayerState.BOT:
			card.hide()
		else:
			card.show()
		var random_resource = temp_resources.pick_random()
		if random_resource.unique:
			temp_resources.erase(random_resource)
		card.choose_card_resource(random_resource)
		if reroll:
			card.flip()
		card.enable()


func update_victory_points():
	$VBoxContainer/VBoxContainer/Victory.text = "👑 " + str(player.victory_points)


func setup_rerolls():
	if player.player_state == Player.PlayerState.BOT:
		reroll_button.visible = false
	else:
		reroll_button.visible = true
	var bonus_text = ""
	if player.bonus_rerolls > 0:
		pass
		#bonus_text = " Includes Bonus"
	reroll_button.get_node("Label").text = "x" + str(player.rerolls)


# reroll button
func _on_button_pressed():
	if player.rerolls > 0:
		%AudioStreamPlayer.stream = dice_sfx
		%AudioStreamPlayer.play()
	emit_signal("reroll_pressed", self) #Caught by game scene

func create_stylebox():
	new_stylebox_normal.border_width_top = 5
	new_stylebox_normal.border_width_bottom = 5
	new_stylebox_normal.border_width_left = 5
	new_stylebox_normal.border_width_right = 5
	new_stylebox_normal.border_color = Color.SKY_BLUE


func remove_from_card_pool(resource):
	if resource_array.has(resource):
		resource_array.erase(resource)


func update_banish_text():
	if player.banish_amount > 0:
		%Banish.text = "🔥" + " BANISH " + "[x" + str(player.banish_amount) + "]"
	else:
		%Banish.add_theme_color_override("font_color", Color(1,1,1,.5))
		%Banish.text = "NO 🔥 LEFT"


func update_place_text(player):
	if player.place == 1:
		$VBoxContainer/VBoxContainer/Place.text = "🏆 " + "1st"
	elif player.place == 2:
		$VBoxContainer/VBoxContainer/Place.text = "🏆 " + "2nd"
	elif player.place == 3:
		$VBoxContainer/VBoxContainer/Place.text = "🏆 " + "3rd"
	elif player.place == 4:
		$VBoxContainer/VBoxContainer/Place.text = "🏆 " + "4th"


func hide_bot_stats():
	$VBoxContainer/HBoxContainer/Reroll.hide()
	$VBoxContainer/HBoxContainer/HBoxContainer/Banish.hide()
