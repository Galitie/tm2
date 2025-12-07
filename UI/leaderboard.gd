extends Control
class_name Leaderboard
var leaders = {}
var ordered_leaders = []



func _ready():
	name = "Leaderboard"


func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"leaders" : leaders,
	}
	return save_dict


func handle_leaderboard(winner : Player):
	_add_leader(winner)
	_sort_leaders()
	show()


func _sort_leaders():
	var ordered_leaders_keys = leaders.keys()
	ordered_leaders_keys.sort_custom(func(a, b): return leaders[a] > leaders[b])
	for mon_name in ordered_leaders_keys:
		var string : String = str(leaders[mon_name]) + " VP" + " - " + mon_name
		ordered_leaders.append(string)
	print("Ordered Leaders: ", ordered_leaders)


func _add_leader(winner : Player):
	leaders[winner.monster.mon_name] = winner.victory_points
	var mon_names : Array = leaders.keys()
	mon_names.sort_custom(func(a, b): return int(leaders[a]) > int(leaders[b]))
	
	if mon_names.size() > 10:
		for i in range(10, mon_names.size()):
			leaders.erase(mon_names[i])
	print("Leaders: ", leaders)
