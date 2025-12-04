extends Node2D
class_name Game

var total_rounds : int = 7
@export var override_total_rounds : int = -1
@export var debug_mode : bool = true
@export var start_in_fight_mode : bool
@export var override_sudden_death_time : float
@export var disable_customizer : bool

@onready var players : Array[Node]
@onready var monsters: Array[Monster]
@onready var upgrade_menu : Node = $Camera2D/CanvasLayer/UpgradePanel
@onready var sudden_death_label: RichTextLabel = $Camera2D/CanvasLayer/SuddenDeathLabel
@onready var sudden_death_timer: Timer = $SuddenDeathTimer

@onready var sudden_death_overlay: Sprite2D = $Camera2D/CanvasLayer/SuddenDeath
const SUDDEN_DEATH_MAX_RADIUS: float = 1.279
var sudden_death_speed_set : bool = false
var sudden_death_speed : int = 100

@onready var camera: Camera2D = $Camera2D
var camera_tracking: bool = false
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var rankings = $Camera2D/CanvasLayer/Rankings

var current_round : int = 0
var current_mode : Modes
var current_knocked_out_monsters : Array[Monster] = []
enum Modes {FIGHT, UPGRADE, CUSTOMIZE, GAME_END}

var ready_players : Array[Node] = []
var winners = []
var menu_scene = preload("uid://405m25td441q")



func _init():
	Controller.process_mode = Node.PROCESS_MODE_ALWAYS
	Globals.game = self


func _physics_process(_delta: float) -> void:
	listen_for_special_trigger()
	# Sort monsters by Y position every second (for performance reasons)
	await get_tree().create_timer(1.0).timeout
	var depth_entities = get_tree().get_nodes_in_group("DepthEntity")
	depth_entities.sort_custom(SortByY)
	for i: int in range(depth_entities.size()):
		var entity = depth_entities[i]
		entity.z_index = i


func debug_stuff():
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.FIGHT:
		var targetable_monsters: Array[CharacterBody2D] = []
		var monster_collection : Array[Node] = get_tree().get_nodes_in_group("Monster")
		var unkillable_states = ["knockedout", "hurt", "zombie", "getupandgo", "upgradestart", "fightstart"]
		for monster in monster_collection:
			if monster.current_hp > 0 and !unkillable_states.has(monster.state_machine.current_state.name.to_lower()):
				targetable_monsters.append(monster)
		if targetable_monsters.size():
			var target_monster = targetable_monsters.pick_random()
			if target_monster.current_hp > 0 and !unkillable_states.has(target_monster.state_machine.current_state.name):
				target_monster.take_damage(null, "", false, 0, 999)
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.UPGRADE:
		set_fight_mode()
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.CUSTOMIZE:
		$Camera2D/CanvasLayer/CustomizeMenu.disable()
		$Camera2D/CanvasLayer/CustomizeMenu.hide()
		if start_in_fight_mode:
			set_fight_mode()
		else:
			transition_audio("uid://bnfvpcj04flvs", 0.0)
			set_upgrade_mode()

 
func listen_for_special_trigger():
	if current_mode == Modes.FIGHT:
		var specials = $Camera2D/CanvasLayer/Specials.get_children()
		var index = 0
		for player in players:
			var requirements_met = !player.special_used and player.monster.current_hp > 0 and player.has_special and player.monster.state_machine.current_state.name != "Zombie"
			if player.player_state == Player.PlayerState.BOT and requirements_met:
				var rand_chance = randi_range(0,100000000)
				if rand_chance > 99900000:
					player.monster.state_machine.use_special()
					player.special_used = true
					specials[index].add_theme_color_override("font_outline_color", player.monster.player_color)
					specials[index].text = "Special used!"
			elif Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_Y) and requirements_met:
				player.monster.state_machine.use_special()
				player.special_used = true
				specials[index].add_theme_color_override("font_outline_color", player.monster.player_color)
				specials[index].text = "Special used!"
			elif player.monster.current_hp <= 0:
				specials[index].text = ""
			index += 1


func SortByY(a, b):
	return a.global_position.y < b.global_position.y


func _unpause() -> void:
	get_tree().paused = false


func pause_game(length: float = 0.0) -> void:
	get_tree().paused = true
	if length > 0:
		$PauseTimer.start(length)


func freeze_frame(monster: Monster) -> void:
	Globals.game.camera.global_position = monster.global_position
	Globals.game.camera.zoom = Vector2(2.0, 2.0)
	Globals.game.pause_game(1.25)
	camera_tracking = false
	await get_tree().create_tween().tween_property(camera, "zoom", Vector2(0.8, 0.8), 0.1).finished
	await get_tree().create_timer(0.5).timeout
	camera_tracking = true


func _ready():
	# Generate player nodes off of player states
	if Globals.game_length != -1:
		total_rounds = Globals.game_length
	if override_total_rounds != -1:
		total_rounds = override_total_rounds
	var player_counter = 1
	for player in Globals.player_states:
		if player != Player.PlayerState.NONE:
			add_player_node(player_counter)
			player_counter += 1
	players = get_tree().get_nodes_in_group("Player")
	var counter = 0
	for player in players:
		player.player_state = Globals.player_states[counter]
		counter += 1
	
	$Camera2D/CanvasLayer/CustomizeMenu.set_customize_panels(players)
	upgrade_menu.set_upgrade_panels(players)
	$PauseTimer.timeout.connect(_unpause)
	
	sudden_death_overlay.material.set_shader_parameter("Radius", 2.5)
	sudden_death_label.visible = false;
	sudden_death_label.scale = Vector2(4.0, 4.0)
	$SuddenDeathTimer.wait_time = override_sudden_death_time if override_sudden_death_time != 0.00 else $SuddenDeathTimer.wait_time
	
	for player in players:
		monsters.push_back(player.monster)
		player.monster.state_machine.find_child("Pooping").connect("spawn_poop", spawn_poop)
		player.monster.state_machine.find_child("Bombing").connect("spawn_bomb", spawn_bomb)
		player.customize_panel.connect("finished_customizing", _add_ready_player)
		player.customize_panel.connect("not_finished_customizing", _remove_ready_player)
	$Camera2D/CanvasLayer/CustomizeMenu.set_bots_to_ready(players)
	
	for player_index in players.size():
		var player = players[player_index]
		player.controller_port = player_index
		
	for monster in monsters:
		MonsterGeneration.Generate(monster, monster.get_node("root"), MonsterGeneration.parts[MonsterPart.MONSTER_TYPE.BUNNY][MonsterPart.PART_TYPE.BODY])
		#MonsterGeneration.SetColors(monster)
		monster.SetCollisionRefs()
		monster.state_machine.initialize()
	
	var upgrade_cards = upgrade_menu.get_tree().get_nodes_in_group("UpgradeCard")
	var player_upgrade_panels = upgrade_menu.get_tree().get_nodes_in_group("PlayerUpgradePanel")
	for card in upgrade_cards:
		card.connect("card_pressed", card_pressed)
	for player_upgrade_panel in player_upgrade_panels:
		player_upgrade_panel.connect("reroll_pressed", reroll_pressed)
		player_upgrade_panel.update_banish_text()
	
	if debug_mode:
		Globals.game.debug_mode = true
		for player in players:
			player.monster.debug_mode = true
			if player.monster.pre_loaded_cards.size():
				for pre_loaded_card in player.monster.pre_loaded_cards:
					apply_card_resource_effects(pre_loaded_card, player)
	
	if disable_customizer:
		$Camera2D/CanvasLayer/CustomizeMenu.hide()
		$Camera2D/CanvasLayer/CustomizeMenu.disable()
	else:
		set_customize_mode()
	
	if start_in_fight_mode:
		set_fight_mode()
	elif !start_in_fight_mode and disable_customizer:
		set_upgrade_mode()


func _process(_delta):
	if debug_mode:
		debug_stuff()
		
	if Globals.is_sudden_death_mode:
		if sudden_death_speed_set == false:
			sudden_death_speed_set = true
			for player in players:
				player.monster.move_speed += sudden_death_speed
		if camera_tracking:
			var monster_avg_position: Vector2
			var alive_monsters: int
			for monster: Monster in monsters:
				if monster.current_hp > 0:
					monster_avg_position += monster.global_position
					alive_monsters += 1
			if alive_monsters:
				camera.zoom = lerp(camera.zoom, Vector2(1.2, 1.2), 2.5 * _delta)
				camera.global_position = lerp(camera.global_position, monster_avg_position / alive_monsters, 5.0 * _delta)
	if ready_players.size() == players.size() and current_mode == Modes.CUSTOMIZE:
		$Camera2D/CanvasLayer/CustomizeMenu.disable()
		$Camera2D/CanvasLayer/CustomizeMenu.hide()
		if start_in_fight_mode:
			set_fight_mode()
		else:
			set_upgrade_mode()
	if ready_players.size() == 1 and current_mode == Modes.CUSTOMIZE and debug_mode:
		$Camera2D/CanvasLayer/CustomizeMenu.disable()
		$Camera2D/CanvasLayer/CustomizeMenu.hide()
		if start_in_fight_mode:
			set_fight_mode()
		else:
			set_upgrade_mode()
	#TODO: Make a real game end scene, placeholder for playtesting
	if current_mode == Modes.GAME_END and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_packed(menu_scene)


func count_death(monster: Monster):
	monster.remove_from_group("DepthEntity")
	monster.z_index = -1
	if current_knocked_out_monsters.has(monster):
		return
	current_knocked_out_monsters.append(monster)
	if current_knocked_out_monsters.size() == players.size() - 1 || current_knocked_out_monsters.size() >= players.size():
		sudden_death_timer.stop()
		for winner in monsters:
			if !current_knocked_out_monsters.has(winner):
				winner.state_machine.transition_state("dance")
		$RoundOverDelayTimer.start()
		transition_audio("uid://bnfvpcj04flvs", 2.0)


func set_customize_mode():
	upgrade_menu.pause_all_inputs()
	$Camera2D/CanvasLayer/CustomizeMenu.show()
	sudden_death_label.visible = false
	current_mode = Modes.CUSTOMIZE
	for player in players:
		player.monster.move_name_upgrade()
		player.monster.target_point = player.customize_pos
		player.monster.state_machine.transition_state("upgradestart")


func set_upgrade_mode():
	current_mode = Modes.UPGRADE
	clean_up_screen()
	if current_round == 0:
		for player in players:
			player.monster.target_point = player.upgrade_pos
			player.place = 1
			player.upgrade_points = 3
			player.rerolls = 3
	if current_round == total_rounds - 1:
		$Camera2D/CanvasLayer/RoundLabel.add_theme_color_override("font_color", Color.RED)
		$Camera2D/CanvasLayer/RoundLabel.text = "FINAL UPGRADE ROUND"
	for player in players:
		player.monster.unzombify()
		player.monster.state_machine.transition_state("upgradestart")
		player.monster.move_name_upgrade()
	if sudden_death_speed_set:
		sudden_death_speed_set = false
		for player in players:
			player.monster.move_speed -= sudden_death_speed
	sudden_death_label.visible = false
	upgrade_menu.unpause_all_inputs()
	if current_round == 0:
		audio_player.stream = load("uid://bnfvpcj04flvs")
		audio_player.play()
	rankings.visible = false
	rankings.text = "Previous round points:\n"
	$Camera2D/CanvasLayer/Specials.visible = false

	for player in players:
		player.special_used = false
		rankings.text += str(player.name + " (" + player.monster.mon_name + "): " + str(player.victory_points) + " points") + "\n"
		var monster = player.monster
		if !monster.is_in_group("DepthEntity"):
			monster.add_to_group("DepthEntity")
	upgrade_menu.setup()
	upgrade_menu.visible = true


func transition_audio(dest_uid: String, length: float = 1.0) -> void:
	await get_tree().create_tween().tween_property(audio_player, "volume_db", -80.0, length).finished
	audio_player.volume_db = 0.0
	audio_player.stream = load(dest_uid)
	audio_player.play()


func set_fight_mode():
	current_mode = Modes.FIGHT
	current_round += 1
	upgrade_menu.pause_all_inputs()
	upgrade_menu.visible = false
	transition_audio("uid://mysomdex1y7k", 0.5)
	transition_audio("uid://mysomdex1y7k", 0.5)
	reset_specials_text()
	$Camera2D/CanvasLayer/Specials.visible = true
	rankings.visible = true
	if current_round == total_rounds:
		$Camera2D/CanvasLayer/RoundLabel.add_theme_color_override("font_color", Color.RED)
		$Camera2D/CanvasLayer/RoundLabel.add_theme_font_size_override("font_size", 36)
		$Camera2D/CanvasLayer/RoundLabel.text = "FINAL ROUND: " + str(current_round) + " / " + str(total_rounds)
	else:
		$Camera2D/CanvasLayer/RoundLabel.text = "ROUND: " + str(current_round) + " / " + str(total_rounds)
	for player in players:
		var monster = player.monster
		monster.move_name_fight()
		monster.target_point = player.fight_pos
		monster.state_machine.transition_state("fightstart")
	sudden_death_timer.start()


func _on_sudden_death_timer_timeout():
	camera_tracking = true
	
	audio_player.stream = load("uid://bnd7vmemesdbl")
	audio_player.play()
	
	get_tree().create_tween().tween_property(sudden_death_overlay.material, "shader_parameter/Radius", SUDDEN_DEATH_MAX_RADIUS, 0.8).set_trans(Tween.TRANS_EXPO)
	get_tree().create_tween().tween_property(camera, "zoom", Vector2(1.2, 1.2), 0.8).set_trans(Tween.TRANS_ELASTIC)
	get_tree().create_tween().tween_property(sudden_death_label, "visible", true, 0.0).set_delay(0.4)
	await get_tree().create_tween().tween_property(sudden_death_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_EXPO).set_delay(0.4).finished
	pause_game(1.0)
	await get_tree().create_tween().tween_property(sudden_death_label, "scale", Vector2(100.0, 100.0), 0.2).set_trans(Tween.TRANS_EXPO).finished
	Globals.is_sudden_death_mode = true
	sudden_death_label.visible = false


func _on_round_over_delay_timer_timeout():
	camera_tracking = false
	get_tree().create_tween().tween_property(sudden_death_overlay.material, "shader_parameter/Radius", 2.5, 1.0)
	get_tree().create_tween().tween_property(camera, "zoom", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_EXPO)
	get_tree().create_tween().tween_property(camera, "global_position", Vector2(575.0, 325.0), 1.0).set_trans(Tween.TRANS_EXPO)
	
	for player in players:
		if player.monster.current_hp > 0 and player.monster not in current_knocked_out_monsters:
			current_knocked_out_monsters.append(player.monster)
			break
	sudden_death_timer.stop()
	Globals.is_sudden_death_mode = false
	var victory_points_gained = 0
	for monster in current_knocked_out_monsters:
		monster.player.victory_points += victory_points_gained
		if victory_points_gained == 0:
			victory_points_gained = 1
		elif victory_points_gained == 1:
			victory_points_gained = 3
		elif victory_points_gained == 3:
			victory_points_gained = 5
	clear_knocked_out_monsters()
	players.sort_custom(func(a, b): return a.victory_points > b.victory_points)
	var game_over = check_if_game_over()
	if !game_over:
		var current_place = 0
		var prev_points = -1
		var rerolls = 0
		for player in players:
			player.monster.move_name_upgrade()
			player.monster.target_point = player.upgrade_pos

			if player.victory_points != prev_points:
				current_place += 1
				rerolls += 1
				prev_points = player.victory_points

			player.place = current_place
			player.rerolls = rerolls + player.bonus_rerolls

		for player in players:
			if player.randomize_upgrade_points:
				player.upgrade_points = randi_range(1, 6)
			else:
				if player.place == 1:
					player.upgrade_points = 2
				elif player.place == 2:
					player.upgrade_points = 3
				elif player.place == 3:
					player.upgrade_points = 4
				elif player.place == 4:
					player.upgrade_points = 5
			player.upgrade_panel.update_place_text(player)
		set_upgrade_mode()

	print("Current Round: ", current_round)
	for player in players:
		print(player.name, "(", player.monster.mon_name, ") : ", player.victory_points, " points")
	print("\n")


func _on_upgrade_over_delay_timer_timeout():
	set_fight_mode()


func card_pressed(card : Sprite2D, acc_index : int, input, button):
	var player : Player = card.upgrade_panel.player
	if input == JOY_BUTTON_Y and player.banish_amount > 0:
		player.banish_amount -= 1
		card.upgrade_panel.update_banish_text()
		await player.upgrade_panel.burn_card(button)
		player.upgrade_panel.resource_array.erase(card.chosen_resource)
		check_if_upgrade_round_over(card, player)
		return
	if input == JOY_BUTTON_Y:
		return
	if card.chosen_resource.parts_and_acc.size() > 0:
		if acc_index < card.chosen_resource.parts_and_acc.size() :
			var part : MonsterPart = card.chosen_resource.parts_and_acc[acc_index]
			MonsterGeneration.AddPartToMonster(player.monster, part)
	var resource_array : Array[Resource] = card.upgrade_panel.resource_array
	player.upgrade_points -= 1
	card.upgrade_panel.upgrade_title.text = "UPG POINTS [x" + str(player.upgrade_points) + "]"
	apply_card_resource_effects(card.chosen_resource, player)
	check_if_upgrade_round_over(card, player)


func apply_card_resource_effects(card_resource : Resource, player):
	var attributes = [
		[card_resource.attribute_1, card_resource.attribute_amount_1],
		[card_resource.attribute_2, card_resource.attribute_amount_2],
		[card_resource.attribute_3, card_resource.attribute_amount_3]
	]
	for attr_data in attributes:
		var attr = attr_data[0]
		var amount = attr_data[1]
		if attr != CardResourceScript.Attributes.NONE:
			apply_card_attribute(attr, amount, player)
	if card_resource.state_id:
		match card_resource.state_id:
			"poop_summon":
				player.poop_summons = true 
			"more_poops":
				player.more_poops = true
			"dbl_dmg":
				player.monster.damage_dealt_mult = 1.50
				player.monster.damage_received_mult = 1.75
			"larger_poops":
				player.larger_poops = true
			"chaser":
				var chase_index = player.monster.state_machine.keys.find("chase")
				player.monster.state_machine.weights[chase_index] += .50
			"blocker":
				var block_index = player.monster.state_machine.keys.find("block")
				player.monster.state_machine.weights[block_index] += .50
			"mirrorblock":
				player.monster.state_machine.state_choices[card_resource.Type].append(card_resource.state_id)
			"mirrorblock_all":
				player.monster.state_machine.block_values.erase("block")
			"attacker":
				var basic_attack_index = player.monster.state_machine.keys.find("basic_attack")
				player.monster.state_machine.weights[basic_attack_index] += .50
			"shield_breaker":
				player.shield_breaker = true
			"pooper":
				var other_index = player.monster.state_machine.keys.find("poop")
				player.monster.state_machine.weights[other_index] += .50
			"thorns":
				#player.monster.thorns = true
				player.monster.set_thorns()
			"death_explode":
				player.death_explode = true
			"larger":
				player.monster.root.scale += Vector2(.15, .15)
				player.monster.body_collision.scale += Vector2(.15, .15)
				player.current_big_cards += 1
				if player.current_big_cards >= 3:
					player.upgrade_panel.remove_from_card_pool(card_resource)
			"smaller":
				player.monster.root.scale -= Vector2(.15, .15)
				player.monster.body_collision.scale -= Vector2(.15, .15)
				player.current_small_cards += 1
				if player.current_small_cards >= 3:
					player.upgrade_panel.remove_from_card_pool(card_resource)
			"matrix":
				player.matrix = true
			"super_matrix":
				player.super_matrix = true
			"specialblock":
				player.monster.state_machine.state_choices[card_resource.Type].clear()
				player.monster.state_machine.state_choices[card_resource.Type].append(card_resource.state_id)
				player.special_name = "BLOCKED UP"
				player.has_special = true
			"specialattack":
				player.monster.state_machine.state_choices[card_resource.Type].clear()
				player.monster.state_machine.state_choices[card_resource.Type].append(card_resource.state_id)
				player.special_name = "QUICK(ER) ATTACK"
				player.has_special = true
			"specialpoop":
				player.monster.state_machine.state_choices[card_resource.Type].clear()
				player.monster.state_machine.state_choices[card_resource.Type].append(card_resource.state_id)
				player.special_name = "SQUEEZE ONE OUT"
				player.has_special = true
			"poop_on_hit":
				player.poop_on_hit = true
			"slime_trail":
				player.slime_trail = true
			"block_longer":
				player.block_longer = true
			"zombie":
				player.zombie = true
			"zombie_sudden_death":
				player.zombie_sudden_death = true
			"larger_slimes":
				player.larger_slimes = true
			"longer_slime":
				player.longer_slimes = true
			"more_slime":
				player.monster.slime_timer.wait_time = .50
			"bite_heal_more":
				player.bite_heal_more = true
			"bombs_only":
				player.monster.state_machine.state_choices["poop"].clear()
				player.monster.state_machine.state_choices["poop"].append("bombing")
			_:
				player.monster.state_machine.state_choices[card_resource.Type].append(card_resource.state_id)
	if card_resource.remove_specific_states.size():
		for state_index in card_resource.remove_specific_states:
			player.monster.state_machine.weights[state_index] = 0
	if card_resource.unlocked_cards:
		for card in card_resource.unlocked_cards:
			if !player.upgrade_panel.resource_array.has(card):
				player.upgrade_panel.resource_array.append(load(card.get_path()))
	if card_resource.remove_cards:
		for card in card_resource.remove_cards:
			if player.upgrade_panel.resource_array.has(card):
				player.upgrade_panel.resource_array.erase(card)
	if card_resource.unique:
		player.upgrade_panel.resource_array.erase(card_resource)


func apply_card_attribute(attribute, amount, player):
	match attribute:
		CardResourceScript.Attributes.HP:
			player.monster.modify_max_hp(amount)
			player.monster.modify_hp(null, player.monster.max_hp)
		CardResourceScript.Attributes.MOVE_SPEED:
			player.monster.move_speed += amount
		CardResourceScript.Attributes.BASE_DAMAGE:
			player.monster.base_damage += amount
		CardResourceScript.Attributes.REROLL:
			player.bonus_rerolls += amount
		CardResourceScript.Attributes.UPGRADE_POINTS:
			player.randomize_upgrade_points = true
		CardResourceScript.Attributes.CRIT_PERCENT:
			player.monster.crit_chance += amount
		CardResourceScript.Attributes.CRIT_MULTIPLIER:
			player.monster.crit_multiplier += amount


func check_if_upgrade_round_over(card, player):
	var upgrade_panel = card.upgrade_panel
	if player.upgrade_points > 0:
		var deep_copy = upgrade_panel.resource_array.duplicate(true)
		for panel_card in upgrade_panel.upgrade_cards:
			if panel_card.chosen_resource.unique:
				deep_copy.erase(panel_card.chosen_resource)
		card.choose_card_resource(deep_copy.pick_random())
	else:
		upgrade_panel.disable_cards()
		upgrade_panel.reroll_button.visible = false
		upgrade_panel.upgrade_title.text = "DONE UPGRADING"
	var players_have_no_points = true
	for p in players:
		if p.upgrade_points > 0:
			players_have_no_points = false
			break
	if players_have_no_points:
		$UpgradeOverDelayTimer.start()


func reroll_pressed(upgrade_panel):
	var player = upgrade_panel.player
	if player.rerolls > 0 and player.upgrade_points > 0:
		player.rerolls -= 1
		upgrade_panel.setup_cards(true)
	if player.rerolls != 0 and player.upgrade_points > 0:
		var bonus_text = ""
		if player.bonus_rerolls > 0:
			#bonus_text = " Includes Bonus"
			pass
	upgrade_panel.reroll_button.get_node("Label").text = "x" + str(player.rerolls)


func check_if_game_over() -> bool:
	if current_round >= total_rounds:
		handle_game_over()
		return true
	else:
		return false


func handle_game_over():
	print("Game over - check for ties")
	upgrade_menu.pause_all_inputs()
	current_mode = Modes.GAME_END
	upgrade_menu.visible = false
	clean_up_screen()
	players.sort_custom(func(a, b): return a.victory_points > b.victory_points)
	rankings.visible = true
	rankings.text = "Rankings:\n"
	for player in players:
		player.monster.move_name_upgrade()
		player.monster.unzombify()
		player.monster.state_machine.transition_state("upgradestart")
		rankings.text += str(player.name + " (" + player.monster.mon_name + "): " + str(player.victory_points) + " points") + "\n"
	var highest_score = players[0].victory_points
	winners = players.filter(func(p): return p.victory_points == highest_score)
	if winners.size() == 1:
		print("Winner:", winners[0].name)
		$Camera2D/CanvasLayer/WinnersLabel.text = "WINNER! (Press START to play again)"
		$Camera2D/CanvasLayer/WinnersLabel.show()
		for player in players:
			player.monster.target_point = player.customize_pos
			if player not in winners:
				player.get_child(0).hide()
	else:
		print("It's a tie!")
		$Camera2D/CanvasLayer/WinnersLabel.text = "THERE'S A TIE!"
		$Camera2D/CanvasLayer/WinnersLabel.show()
		await get_tree().create_timer(2.5).timeout
		$Camera2D/CanvasLayer/WinnersLabel.hide()
		$SuddenDeathTimer.wait_time = .5
		set_fight_mode()
		for player in players:
			player.monster.target_point = player.fight_pos
			if player not in winners:
				player.zombie = false
				player.zombie_sudden_death = false
				player.monster.take_damage(null, "", false, 0, 999)


func clear_knocked_out_monsters():
	current_knocked_out_monsters.clear()


func spawn_poop(monster):
	monster.play_generic_sound("uid://c2wiqjug8rgf4", -8.0)
	var poop = preload("uid://b03qji6okxywb").instantiate()
	poop.add_to_group("DepthEntity")
	poop.monster = monster
	poop.move_speed = monster.move_speed
	poop.global_position = monster.poop_checker.global_position
	if monster.player.poop_summons:
		poop.is_a_summon = true
	if monster.player.larger_poops:
		poop.scale += Vector2(randf_range(.50,.70), randf_range(.50,.70))
		poop.poop_shoot_interval = randf_range(3,10)	
	else:
		poop.poop_shoot_interval = randf_range(5,15)
	add_child(poop)
	poop.add_to_group("CleanUp")


func spawn_bomb(monster):
	monster.play_generic_sound("uid://c2wiqjug8rgf4", -8.0)
	var bomb = preload("uid://gxo3acon6q5t").instantiate()
	bomb.monster = monster
	bomb.global_position = monster.poop_checker.global_position
	if monster.player.larger_poops:
		bomb.scale += Vector2(.50, .50)
	add_child(bomb)	


func clean_up_screen():
	var items = get_tree().get_nodes_in_group("CleanUp")
	for item in items:
		item.queue_free()


func _add_ready_player(player):
	ready_players.append(player)


func _remove_ready_player(player):
	var index = ready_players.find(player)
	ready_players.remove_at(index)


func reset_specials_text():
	var specials = $Camera2D/CanvasLayer/Specials.get_children()
	var index = 0
	for player in players:
		specials[index].text = ""
		if player.monster.state_machine.special_values != []:
			specials[index].add_theme_color_override("font_outline_color", player.monster.player_color)
			specials[index].text = "Press Y: " + player.special_name
		index += 1


func add_player_node(player_number):
	var player_node : Player = Player.new()
	var monster : Monster = load("uid://d3fkc0o45x3ja").instantiate() as Monster
	match player_number:
		1:
			player_node.name = "Player1"
			monster.player_color = Color.RED
			player_node.customize_pos = Vector2(149,400)
			player_node.upgrade_pos = Vector2(149, 575)
			player_node.fight_pos = Vector2(252,200)
		2:
			player_node.name = "Player2"
			monster.player_color = Color.BLUE
			player_node.customize_pos = Vector2(436,400)
			player_node.upgrade_pos = Vector2(436, 575)
			player_node.fight_pos = Vector2(870,171)

		3:
			player_node.name = "Player3"
			monster.player_color = Color.YELLOW
			player_node.customize_pos = Vector2(720,400)
			player_node.upgrade_pos = Vector2(720, 575)
			player_node.fight_pos = Vector2(240,427)
		4:
			player_node.name = "Player4"
			monster.player_color = Color.GREEN
			player_node.customize_pos = Vector2(1000,400)
			player_node.upgrade_pos = Vector2(1000, 575)
			player_node.fight_pos = Vector2(860,455)
	
	monster.add_to_group("Monster")
	player_node.add_to_group("Player")
	player_node.add_child(monster)
	var players_node = get_tree().get_root().get_node("Game/Players")
	players_node.add_child(player_node)
	player_node.monster = monster
	monster.player = player_node
	
