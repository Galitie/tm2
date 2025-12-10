extends Control
class_name Leaderboard
var leaders = {}
var ordered_leaders = []



func _ready():
	if name != "Leaderboard":
		name = "Leaderboard"
	hide()


func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"leaders" : leaders,
	}
	return save_dict


func handle_leaderboard(players : Array):
	if players != null:
		for player in players:
			_add_leader(player)
	_sort_leaders()
	_show_leaders_in_list()


func _sort_leaders():
	var ordered_leaders_keys = leaders.keys()
	ordered_leaders_keys.sort_custom(func(a, b): return leaders[a] > leaders[b])
	var counter = 1
	for mon_name in ordered_leaders_keys:
		var string : String = "#" + str(counter) + " " + mon_name + " - " + str(int(leaders[mon_name])) + " VP"
		ordered_leaders.append(string)
		counter += 1
	print("Ordered Leaders: ", ordered_leaders)


func _show_leaders_in_list():
	for leader in ordered_leaders:
		$VBoxContainer/Board.add_item(leader)
	show()

func _add_leader(winner : Player):
	leaders[winner.monster.mon_name] = winner.victory_points
	var mon_names : Array = leaders.keys()
	mon_names.sort_custom(func(a, b): return int(leaders[a]) > int(leaders[b]))
	
	if mon_names.size() > 10:
		for i in range(10, mon_names.size()):
			leaders.erase(mon_names[i])
