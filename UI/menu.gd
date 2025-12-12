extends Control

@onready var human_button_array: Array[Node] = [$"MarginContainer/HumanMenu/VBoxContainer/1", $"MarginContainer/HumanMenu/VBoxContainer/2", $"MarginContainer/HumanMenu/VBoxContainer/3", $"MarginContainer/HumanMenu/VBoxContainer/4" ]
var current_user_position_in_human_button_array : int = 0

var bot_button_array: Array[Node]
var current_user_position_in_bot_button_array : int = 0

@onready var round_button_array: Array[Node] = [$"MarginContainer/RoundMenu/VBoxContainer/1", $"MarginContainer/RoundMenu/VBoxContainer/2", $"MarginContainer/RoundMenu/VBoxContainer/3"]
var current_user_position_in_round_button_array : int = 0

var new_stylebox_normal = StyleBoxFlat.new()
var input_paused : bool = false

var human_players_selected : bool = false
var bot_players_selected : bool = false
var rounds_selected : bool = false


func _ready():
	current_user_position_in_human_button_array = 0
	create_stylebox()


func _physics_process(_delta):
	if input_paused:
		return
	
	var dpad_vertical_input: int =  Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_DOWN) - Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_UP)
	var dpad_horizontal_input: int =  Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_RIGHT) - Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_LEFT)
	if !human_players_selected:
		var button = human_button_array[current_user_position_in_human_button_array]

		if current_user_position_in_human_button_array == 0:
			button.add_theme_stylebox_override("panel", new_stylebox_normal)

		
		if Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_DOWN) || Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_UP):
			current_user_position_in_human_button_array += dpad_vertical_input
			if current_user_position_in_human_button_array <= -1:
				current_user_position_in_human_button_array = human_button_array.size() - 1
			if current_user_position_in_human_button_array >= human_button_array.size():
				current_user_position_in_human_button_array = 0

			button = human_button_array[current_user_position_in_human_button_array]
			button.add_theme_stylebox_override("panel", new_stylebox_normal)
			for other_button in human_button_array:
				if other_button != button:
					other_button.remove_theme_stylebox_override("panel")
			
		if Controller.IsButtonJustPressed(0, JOY_BUTTON_A):
			button = human_button_array[current_user_position_in_human_button_array]
			_on_button_pressed(current_user_position_in_human_button_array)
	elif !bot_players_selected:
		var button = bot_button_array[current_user_position_in_bot_button_array]
		if current_user_position_in_bot_button_array == 0:
			button.add_theme_stylebox_override("panel", new_stylebox_normal)
		
		if Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_DOWN) || Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_UP):
			current_user_position_in_bot_button_array += dpad_vertical_input
			if current_user_position_in_bot_button_array <= -1:
				current_user_position_in_bot_button_array = bot_button_array.size() - 1
			if current_user_position_in_bot_button_array >= bot_button_array.size():
				current_user_position_in_bot_button_array = 0

			button = bot_button_array[current_user_position_in_bot_button_array]
			button.add_theme_stylebox_override("panel", new_stylebox_normal)
			for other_button in bot_button_array:
				if other_button != button:
					other_button.remove_theme_stylebox_override("panel")
			
		if Controller.IsButtonJustPressed(0, JOY_BUTTON_A):
			button = bot_button_array[current_user_position_in_bot_button_array]
			if button.get_child(0).disabled == false:
				_on_button_pressed(current_user_position_in_bot_button_array)
	
	if human_players_selected and bot_players_selected:
		var button = round_button_array[current_user_position_in_round_button_array]

		if current_user_position_in_round_button_array == 0:
			button.add_theme_stylebox_override("panel", new_stylebox_normal)

		if Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_DOWN) || Controller.IsButtonJustPressed(0, JOY_BUTTON_DPAD_UP):
			current_user_position_in_round_button_array += dpad_vertical_input
			if current_user_position_in_round_button_array <= -1:
				current_user_position_in_round_button_array = round_button_array.size() - 1
			if current_user_position_in_round_button_array >= round_button_array.size():
				current_user_position_in_round_button_array = 0

			button = round_button_array[current_user_position_in_round_button_array]
			button.add_theme_stylebox_override("panel", new_stylebox_normal)
			for other_button in round_button_array:
				if other_button != button:
					other_button.remove_theme_stylebox_override("panel")
			
		if Controller.IsButtonJustPressed(0, JOY_BUTTON_A):
			button = round_button_array[current_user_position_in_round_button_array]
			_on_button_pressed(current_user_position_in_round_button_array)
		
		

func create_stylebox():
	new_stylebox_normal.border_width_top = 5
	new_stylebox_normal.border_width_bottom = 5
	new_stylebox_normal.border_width_left = 5
	new_stylebox_normal.border_width_right = 5
	new_stylebox_normal.border_color = Color.SKY_BLUE


func _on_button_pressed(button_index):
	input_paused = true
	new_stylebox_normal.border_color = Color.GREEN
	new_stylebox_normal.bg_color = Color.GREEN
	await get_tree().create_timer(0.15).timeout
	
	if !human_players_selected:
		match button_index:
			0:
				Globals.player_states[0] = Player.PlayerState.HUMAN
			1:
				for player in 2:
					Globals.player_states[player] = Player.PlayerState.HUMAN
			2:
				for player in 3:
					Globals.player_states[player] = Player.PlayerState.HUMAN
			3:
				for player in 4:
					Globals.player_states[player] = Player.PlayerState.HUMAN
				input_paused = true
				hide()
				Globals.game.set_up_game()
				return
				
		$MarginContainer/HumanMenu.hide()
		$MarginContainer/BotsMenu.show()
		build_bot_buttons(button_index + 1)
		human_players_selected = true
		input_paused = false
	elif !bot_players_selected:
		input_paused = true
		bot_players_selected = true
		match bot_button_array[int(button_index)].get_child(0).text:
			"No Bots":
				input_paused = true
				hide()
				Globals.game.set_up_game()
				return
			"1":
				var counter = 1
				var index = 0
				for player in Globals.player_states:
					if player == Player.PlayerState.NONE and counter > 0:
						Globals.player_states[index] = Player.PlayerState.BOT
						counter -= 1
					index += 1
			"2":
				var counter = 2
				var index = 0
				for player in Globals.player_states:
					if player == Player.PlayerState.NONE and counter > 0:
						Globals.player_states[index] = Player.PlayerState.BOT
						counter -= 1
					index += 1
			"3":
				var counter = 3
				var index = 0
				for player in Globals.player_states:
					if player == Player.PlayerState.NONE and counter > 0:
						Globals.player_states[index] = Player.PlayerState.BOT
						counter -= 1
					index += 1
		input_paused = false
		$MarginContainer/BotsMenu.hide()
		$MarginContainer/RoundMenu.show()
	
	elif human_players_selected and bot_players_selected:
		input_paused = true
		rounds_selected = true
		match button_index:
			0:
				Globals.game_length = 7
			1:
				Globals.game_length = 5
			2:
				Globals.game_length = 10
		input_paused = false
	
	if human_players_selected and bot_players_selected and rounds_selected:
		input_paused = true
		hide()
		Globals.game.set_up_game()
		return


func build_bot_buttons(human_player_amount : int):
	match human_player_amount:
		4:
			input_paused = true
			hide()
			Globals.game.set_up_game()
			return
		3:
			$"MarginContainer/BotsMenu/VBoxContainer/2".hide()
			$"MarginContainer/BotsMenu/VBoxContainer/3".hide()
		2:
			$"MarginContainer/BotsMenu/VBoxContainer/3".hide()
		1:
			$"MarginContainer/BotsMenu/VBoxContainer/0/CardInfo".disabled = true
			$"MarginContainer/BotsMenu/VBoxContainer/0/CardInfo".set_block_signals(true)
			$"MarginContainer/BotsMenu/VBoxContainer/0/CardInfo".add_theme_color_override("font_disabled_color", Color.RED)
	
	var nodes = $MarginContainer/BotsMenu/VBoxContainer.get_children()
	for node in nodes:
		if node == nodes[0]:
			continue
		if node.visible:
			bot_button_array.append(node)


func _on_card_info_pressed(extra_arg_0: String) -> void:
	pass # Replace with function body.
