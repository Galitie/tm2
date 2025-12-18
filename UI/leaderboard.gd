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
	_copy_leaders_to_visible_list(players)
	show()


func _sort_leaders():
	var ordered_leaders_keys = leaders.keys()
	ordered_leaders_keys.sort_custom(func(a, b): return leaders[a] > leaders[b])
	var counter = 1
	ordered_leaders = []
	for mon_name in ordered_leaders_keys:
		var string : String = "#" + str(counter) + " " + mon_name + " - " + str(int(leaders[mon_name])) + " VP"
		ordered_leaders.append(string)
		counter += 1


func _copy_leaders_to_visible_list(players):
	for leader in ordered_leaders:
		var icon : Texture2D = null
		for player in players:
			if leader.find(player.monster.mon_name) != -1:
				icon = load("res://UI/star.png")
		$VBoxContainer/Board.add_item(leader, icon)


func _add_leader(player : Player):
	leaders[player.monster.mon_name] = player.victory_points
	var mon_names : Array = leaders.keys()
	mon_names.sort_custom(func(a, b): return int(leaders[a]) > int(leaders[b]))
	
	if mon_names.size() > 10:
		for i in range(10, mon_names.size()):
			leaders.erase(mon_names[i])

# leaders {"monster name" : points}
# ordered_leaders ["string with monster name"]
# players [player.mon_name]
# if leader in ordered_leader.has[player.mon_name]:
# add star icon
