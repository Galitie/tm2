extends MarginContainer
class_name PlayerCustomizePanel

@onready var title = $VBoxContainer/Title/Label
var player : Player
@onready var button_array: Array[Node] = [$VBoxContainer/Custom1, $VBoxContainer/Custom2, $VBoxContainer/Done]
var current_user_position_in_button_array : int = 0
var new_stylebox_normal = StyleBoxFlat.new()
var disabled : bool = false
var waiting_for_ready_up : bool = false
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


func create_stylebox():
	new_stylebox_normal.border_width_top = 5
	new_stylebox_normal.border_width_bottom = 5
	new_stylebox_normal.border_width_left = 5
	new_stylebox_normal.border_width_right = 5
	new_stylebox_normal.border_color = Color.SKY_BLUE
	
	

func _on_button_pressed(button_index):
	match button_index:
		0:
			MonsterGeneration.RandomizeColor(player.monster)
		1:
			player.monster.generate_random_name()
		2:
			waiting_for_ready_up = true
			new_stylebox_normal.border_color = Color.GREEN
			new_stylebox_normal.bg_color = Color.GREEN
			finished_customizing.emit(player)
			done_text.text = "Please Wait..."
			done_description.text = "Press 'B' to go back to customizing"
