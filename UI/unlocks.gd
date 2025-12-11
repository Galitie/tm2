extends Control
class_name Unlocks

var unlocked_locked_resources : Array[Resource] = []

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"unlocked_locked_resources" : unlocked_locked_resources,
		"counters" : counters,
	}
	return save_dict


# Load game, load these counters from the save file
# Save game, save the new counters to the save file
var counters = {
	"total_bunnies_killed" : 0,
	"total_games_played" : 0,
	"total_damage_dealt" : 0,
	"total_poops_pooped" : 0
}

# Unlock options?
# Accessories
# Color palletes
# Soundtracks
# Backgrounds
# Cards
# 	Poop summons
#	Bomb build
#	Slime trail build
#	Zombie
#	Vampire/Bite

func add_counter(property : String, adjustment : int):
	counters[property] += adjustment
	print(counters)
	check_if_unlocked()


func check_if_unlocked():
	if counters.total_bunnies_killed >= 25:
		pass
	if counters.total_bunnies_killed >= 100:
		pass
	if counters.total_games_played >= 3:
		pass
	if counters.total_games_played >= 10:
		pass
	if counters.total_damage_dealt >= 100:
		pass
	if counters.total_damage_dealt >= 500:
		pass
	if counters.total_damage_dealt >= 1000:
		pass
	if counters.total_poops_pooped >= 10:
		pass
	if counters.total_poops_pooped >= 100:
		pass
