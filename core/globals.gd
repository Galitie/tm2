extends Node
var game : Game
var is_sudden_death_mode : bool = false
var debug_mode : bool = false
var player_states : Array[Player.PlayerState] = [Player.PlayerState.NONE, Player.PlayerState.NONE, Player.PlayerState.NONE, Player.PlayerState.NONE]
var game_length : int = -1


func get_window_size_diff() -> float:
	var window_size: Vector2 = DisplayServer.window_get_size()
	var size_diff: float = (window_size.x + window_size.y) / (1152 + 648)
	return size_diff


func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		var node_data = node.call("save")
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)


# To clear any loaded data, go to AppData/Roaming/Godot/app_userdata/TM2
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return

	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.data

		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		#new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
