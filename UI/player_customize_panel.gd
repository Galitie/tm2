extends MarginContainer
class_name PlayerCustomizePanel

var player : Player
var monster_pos : Vector2
var mon_names : Array[String] = []
var mon_colors : Array[Array] = []

@onready var button_array: Array[Node] = [$VBoxContainer/Custom2, $VBoxContainer/Custom1, $VBoxContainer/Done]
var current_user_position_in_button_array : int = 0

var new_stylebox_normal = StyleBoxFlat.new()
var disabled : bool = false
var waiting_for_ready_up : bool = false

@onready var title = $VBoxContainer/Title/Label
@onready var done_text = $VBoxContainer/Done/CardInfo/MarginContainer/VBoxContainer/TitleDescription/Title
@onready var done_description = $VBoxContainer/Done/CardInfo/MarginContainer/VBoxContainer/TitleDescription/Description


signal finished_customizing(player)
signal not_finished_customizing(player)


func _ready():
	current_user_position_in_button_array = 0
	create_stylebox()


func _physics_process(_delta):
	var button = button_array[current_user_position_in_button_array]
	if waiting_for_ready_up:
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_B):
			new_stylebox_normal.border_color = Color.SKY_BLUE
			new_stylebox_normal.bg_color = Color.WEB_GRAY
			not_finished_customizing.emit(player)
			done_text.text = "READY UP!"
			done_description.text = "I'm finished customizing"
			waiting_for_ready_up = false
			current_user_position_in_button_array = 0
			button = button_array[current_user_position_in_button_array]
			for other_button in button_array:
				if other_button != button:
					other_button.remove_theme_stylebox_override("panel")
	if !disabled and !waiting_for_ready_up:
		if current_user_position_in_button_array == 0:
			button.add_theme_stylebox_override("panel", new_stylebox_normal)
		var dpad_vertical_input: int =  Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_DOWN) - Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_UP)
		var dpad_horizontal_input: int =  Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_RIGHT) - Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_LEFT)
		
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_DOWN) || Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_DPAD_UP):
			current_user_position_in_button_array += dpad_vertical_input
			if current_user_position_in_button_array <= -1:
				current_user_position_in_button_array = button_array.size() - 1
			if current_user_position_in_button_array >= button_array.size():
				current_user_position_in_button_array = 0

			button = button_array[current_user_position_in_button_array]
			button.add_theme_stylebox_override("panel", new_stylebox_normal)
			for other_button in button_array:
				if other_button != button:
					other_button.remove_theme_stylebox_override("panel")
			
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_A):
			button = button_array[current_user_position_in_button_array]
			_on_button_pressed(current_user_position_in_button_array)
		
		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_B):
			if current_user_position_in_button_array == 0: #if current highlighted button is name
				if mon_names.size() >= 2:
					var previous_element = mon_names.size() - 2
					var previous_name = mon_names[previous_element]
					player.monster.name_label.text = previous_name
					player.monster.upgrade_label.text = previous_name
					player.monster.mon_name = previous_name
					mon_names.pop_back()

		if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_B):
			if current_user_position_in_button_array == 1: #if current highlighted button is color
				if mon_colors.size() >= 2:
					var previous_element = mon_colors.size() - 2
					var previous_color = mon_colors[previous_element]
					MonsterGeneration.RandomizeColor(player.monster, previous_color)
					mon_colors.pop_back()


func create_stylebox():
	new_stylebox_normal.set_border_width_all(5)
	new_stylebox_normal.border_color = Color.SKY_BLUE


func handle_bot():
	$VBoxContainer/Title.hide()
	$VBoxContainer/Custom1.hide()
	$VBoxContainer/Custom2.hide()
	waiting_for_ready_up = true
	finished_customizing.emit(player)
	
	var bot_stylebox = StyleBoxFlat.new()
	bot_stylebox.set_border_width_all(5)
	bot_stylebox.bg_color = Color.GREEN
	bot_stylebox.border_color = Color.GREEN
	$VBoxContainer/Done.add_theme_stylebox_override("panel", bot_stylebox)
	
	done_text.text = "Finished Customizing"
	done_description.text = "Bots are good to go"


func _on_button_pressed(button_index):
	match button_index:
		1:
			var random_color = MonsterGeneration.RandomizeColor(player.monster)
			if mon_colors.size() < 5:
				mon_colors.append(random_color)
			else:
				mon_colors.pop_front()
				mon_colors.append(random_color)
			
		0:
			var mon_name = player.monster.generate_random_name()
			if mon_names.size() < 5:
				mon_names.append(mon_name)
			else:
				mon_names.pop_front()
				mon_names.append(mon_name)
				
		2:
			waiting_for_ready_up = true
			finished_customizing.emit(player)
			new_stylebox_normal.border_color = Color.GREEN
			new_stylebox_normal.bg_color = Color.GREEN
			done_text.text = "Please Wait..."
			done_description.text = "Press 'B' to go back to customizing"
