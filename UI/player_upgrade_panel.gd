extends MarginContainer
class_name PlayerUpgradePanel

signal reroll_pressed(upgrade_panel)

@onready var reroll_button : Button = $VBoxContainer/Reroll
@onready var upgrade_cards = [$VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3 ]
@onready var upgrade_title = $VBoxContainer/UpgradeTitle/Label

var player : Player
var resource_array: Array[Resource] = [load("uid://n6000538073l"), load("uid://cgypuyq157lm6"), load("uid://phcwpn7m4yun"), load("uid://f53own34678k"), load("res://Cards/Resources/thorns.tres"), load("uid://x788fm7x6b4i"), load("uid://bd56nejnv5k61"), load("uid://dowb4h6fynu1t"), load("uid://d38rynb3vrmjg"), load("uid://d1mv22yolom78"), load("uid://2dwrrigu8sux"), load("uid://b1yf5pmgknoky"), load("uid://bn1d6phtvfhry"),load("uid://bkgtuu1m8soho"),load("uid://dyvymb65crfuv"),load("uid://c37d7vyo0m6jb"), load("uid://3aquqn25lskq"), load("uid://cvtqvsltnme3w"), load("uid://cv4dcuvdmk4d"), load("uid://cr0ughlj0g43p"), load("uid://c6dyyjnj08tgh"), load("uid://ds51dyaoyuqjg"), load("uid://b7mqshabtd6un"), load("uid://d4m0ycr7geqti")]
@onready var button_array: Array[Node] = [reroll_button, $VBoxContainer/UpgradeCard1, $VBoxContainer/UpgradeCard2, $VBoxContainer/UpgradeCard3]
var current_user_position_in_button_array : int = 0
var new_stylebox_normal = StyleBoxFlat.new()

var current_user_position_in_accessory_array : int = 0
var in_accessory_menu = false

func _ready():
	for card in upgrade_cards:
		card.upgrade_panel = self
	create_stylebox()


func _physics_process(_delta):
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
			
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_A):
			var button = button_array[current_user_position_in_button_array]
			if button == reroll_button:
				_on_button_pressed()
			else:
				# For navigating the accessory menu
				if button.chosen_resource.parts_and_acc.size() > 0:
					if in_accessory_menu:
						# already in the acc menu and pressed something
						in_accessory_menu = false
						
						button._on_button_pressed(current_user_position_in_accessory_array) #for now
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
					button._on_button_pressed()
		
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


func setup_cards():
	current_user_position_in_button_array = 0
	var temp_resources = resource_array.duplicate(true)
	for card in upgrade_cards:
		var random_resource = temp_resources.pick_random()
		if random_resource.unique:
			temp_resources.erase(random_resource)
		card.choose_card_resource(random_resource)
		card.enable()


func setup_rerolls():
	if player.rerolls > 0:
		reroll_button.text = "🎲 Reroll Upgrades " + "[x" + str(player.rerolls) + "]"
		reroll_button.disabled = false
	else:
		reroll_button.text = "No 🎲 Available"
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
