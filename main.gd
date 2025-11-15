extends Node2D
class_name Game

@export var total_rounds : int = 10
@export var debug_mode : bool = true
@export var start_in_fight_mode : bool
@export var override_sudden_death_time : float
@export var disable_customizer : bool

@onready var players : Array[Node]
@onready var monsters: Array[Monster]
@onready var upgrade_menu : Node = $UpgradePanel
@onready var sudden_death_label: RichTextLabel = $Camera2D/CanvasLayer/SuddenDeathLabel
@onready var sudden_death_timer: Timer = $SuddenDeathTimer

@onready var sudden_death_overlay: Sprite2D = $Camera2D/CanvasLayer/SuddenDeath
const SUDDEN_DEATH_MAX_RADIUS: float = 1.279
var sudden_death_speed_set : bool = false
var sudden_death_speed : int = 100

@onready var camera: Camera2D = $Camera2D
var camera_tracking: bool = false
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var current_round : int
var current_mode : Modes
var current_knocked_out_monsters : Array[Monster] = []
enum Modes {FIGHT, UPGRADE, CUSTOMIZE, GAME_END}

var ready_players : Array[Node] = []


func debug_stuff():
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.FIGHT:
		var targetable_monsters: Array[CharacterBody2D] = []
		var monster_collection : Array[Node] = get_tree().get_nodes_in_group("Monster")
		for monster in monster_collection:
			var state_machine = monster.get_node("StateMachine")
			if monster.current_hp > 0:
				targetable_monsters.append(monster)
		if targetable_monsters.size():
			var target_monster = targetable_monsters.pick_random()
			target_monster.take_damage(null, "", false, 0, 999)
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.UPGRADE:
		set_fight_mode()
	if Input.is_action_just_pressed("ui_accept") and current_mode == Modes.CUSTOMIZE:
		$CustomizeMenu.disable()
		$CustomizeMenu.hide()
		if start_in_fight_mode:
			set_fight_mode()
		else:
			transition_audio("uid://bnfvpcj04flvs", 0.0)
			set_upgrade_mode()


func listen_for_special_trigger():
	if current_mode == Modes.FIGHT:
		var specials = $Specials.get_children()
		var index = 0
		for player in players:
			if player.player_state == Player.PlayerState.BOT and !player.special_used and player.monster.current_hp > 0 and player.has_special:
				var rand_chance = randi_range(0,100000000)
				if rand_chance > 99900000:
					player.monster.state_machine.use_special()
					player.special_used = true
					specials[index].add_theme_color_override("font_outline_color", player.monster.player_color)
					specials[index].text = "Special used!"
			if player.monster.current_hp <= 0:
				specials[index].text = ""
			if Controller.IsButtonJustPressed(player.controller_port, JOY_BUTTON_Y) and !player.special_used and player.monster.current_hp > 0 and player.has_special:
				player.monster.state_machine.use_special()
				player.special_used = true
				specials[index].add_theme_color_override("font_outline_color", player.monster.player_color)
				specials[index].text = "Special used!"
			index += 1


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
	
	if current_knocked_out_monsters.size() == players.size() - 1 || current_knocked_out_monsters.size() >= players.size():
		camera_tracking = false
		get_tree().create_tween().tween_property(sudden_death_overlay.material, "shader_parameter/Radius", 2.5, 1.0)
		get_tree().create_tween().tween_property(camera, "zoom", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_EXPO)
		get_tree().create_tween().tween_property(camera, "global_position", Vector2(575.0, 325.0), 1.0).set_trans(Tween.TRANS_EXPO)


func _ready():
	# Generate player nodes off of player states
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
	
	$CustomizeMenu.set_customize_panels(players)
	$UpgradePanel.set_upgrade_panels(players)
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
	$CustomizeMenu.set_bots_to_ready(players)
	
	if debug_mode:
		Globals.game.debug_mode = true
		for player in players:
			player.monster.debug_mode = true
			if player.monster.pre_loaded_cards.size():
				for pre_loaded_card in player.monster.pre_loaded_cards:
					apply_card_resource_effects(pre_loaded_card, player)
	
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
	
	if disable_customizer:
		$CustomizeMenu.hide()
		$CustomizeMenu.disable()
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
			camera.zoom = lerp(camera.zoom, Vector2(1.2, 1.2), 2.5 * _delta)
			camera.global_position = lerp(camera.global_position, monster_avg_position / alive_monsters, 5.0 * _delta)
	if ready_players.size() == players.size() and current_mode == Modes.CUSTOMIZE:
		$CustomizeMenu.disable()
		$CustomizeMenu.hide()
		if start_in_fight_mode:
			set_fight_mode()
		else:
			set_upgrade_mode()
	if ready_players.size() == 1 and current_mode == Modes.CUSTOMIZE and debug_mode:
		$CustomizeMenu.disable()
		$CustomizeMenu.hide()
		if start_in_fight_mode:
			set_fight_mode()
		else:
			set_upgrade_mode()
	#TODO: Make a real game end scene, placeholder for playtesting
	if current_mode == Modes.GAME_END and Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()


func count_death(monster: Monster):
	monster.remove_from_group("DepthEntity")
	monster.z_index = -1
	current_knocked_out_monsters.append(monster)
	if current_knocked_out_monsters.size() == players.size() - 1 || current_knocked_out_monsters.size() >= players.size():
		sudden_death_timer.stop()
		for winner in monsters:
			if !current_knocked_out_monsters.has(winner):
				winner.state_machine.transition_state("dance")
				print("Monster is dancing")
		$RoundOverDelayTimer.start()
		transition_audio("uid://bnfvpcj04flvs", 2.0)


func set_customize_mode():
	$UpgradePanel.pause_all_inputs()
	$CustomizeMenu.show()
	sudden_death_label.visible = false
	current_mode = Modes.CUSTOMIZE
	for player in players:
		player.monster.move_name_upgrade()
		player.monster.target_point = player.customize_pos
		player.monster.state_machine.transition_state("upgradestart")


func set_upgrade_mode():
	$UpgradePanel.unpause_all_inputs()
	if current_round == 0:
		audio_player.stream = load("uid://bnfvpcj04flvs")
		audio_player.play()
	current_mode = Modes.UPGRADE
	sudden_death_label.visible = false
	if sudden_death_speed_set:
		sudden_death_speed_set = false
		for player in players:
			player.monster.move_speed -= sudden_death_speed
	if debug_mode:
		$Rankings.visible = false
		$Rankings.text = "Previous round points:\n"
	$Specials.visible = false
	$SlimeTimer.stop()
	clean_up_screen()
	players.sort_custom(func(a, b): return a.victory_points > b.victory_points)
	clear_knocked_out_monsters()
	sudden_death_timer.stop()
	Globals.is_sudden_death_mode = false
	var rerolls_amount_counter = 0
	var place_counter = 1
	for player in players:
		player.special_used = false
		player.monster.unzombify()
		if current_round == 0:
			player.place = 1
		else:
			player.place = place_counter
		player.upgrade_panel.update_place_text(player)
		if debug_mode:
			$Rankings.text += str(player.name + " (" + player.monster.mon_name + "): " + str(player.victory_points) + " points") + "\n"
		var monster = player.get_node("Monster")
		monster.move_name_upgrade()
		monster.target_point = player.upgrade_pos
		monster.state_machine.transition_state("upgradestart")
		if !monster.is_in_group("DepthEntity"):
			monster.add_to_group("DepthEntity")
		if player.randomize_upgrade_points:
			player.upgrade_points = randi_range(1,5)
		else:
			player.upgrade_points = 3
		if current_round == 0:
			player.rerolls = 3
		else:
			player.rerolls = rerolls_amount_counter + player.bonus_rerolls
		rerolls_amount_counter += 1
		place_counter += 1
	upgrade_menu.setup()
	upgrade_menu.visible = true
	check_if_game_over()

func transition_audio(dest_uid: String, length: float = 1.0) -> void:
	await get_tree().create_tween().tween_property(audio_player, "volume_db", -80.0, length).finished
	audio_player.volume_db = 0.0
	audio_player.stream = load(dest_uid)
	audio_player.play()


func set_fight_mode():
	transition_audio("uid://mysomdex1y7k", 0.5)
	$UpgradePanel.pause_all_inputs()
	current_mode = Modes.FIGHT
	current_round += 1
	reset_specials_text()
	if debug_mode:
		$Rankings.visible = true
	$Specials.visible = true
	if current_round == total_rounds:
		$RoundLabel.add_theme_color_override("font_color", Color.RED)
		$RoundLabel.add_theme_font_size_override("font_size", 36)
		$RoundLabel.text = "FINAL ROUND: " + str(current_round) + " / " + str(total_rounds)
	else:
		$RoundLabel.text = "ROUND: " + str(current_round) + " / " + str(total_rounds)
	sudden_death_timer.start()
	get_node("UpgradePanel").visible = false
	for player in players:
		var monster = player.get_node("Monster")
		monster.move_name_fight()
		monster.state_machine.transition_state("fightstart")
		monster.target_point = player.fight_pos
	$SlimeTimer.start()


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
	for player in players:
		if player.monster.current_hp > 0 and player.monster not in current_knocked_out_monsters:
			current_knocked_out_monsters.append(player.monster)
			break
	var victory_points_gained = 0
	for monster in current_knocked_out_monsters:
		monster.player.victory_points += victory_points_gained
		victory_points_gained += 1
	set_upgrade_mode()
	print("Current Round: ", current_round)
	for player in players:
		print(player.name, "(", player.monster.mon_name, ") : ", player.victory_points, " points")
	print("\n")


func _on_upgrade_over_delay_timer_timeout():
	set_fight_mode()


func card_pressed(card : PanelContainer, acc_index : int, input, button):
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
				player.monster.damage_dealt_mult *= 1.25
				player.monster.damage_received_mult *= 2.0
			"larger_poops":
				player.larger_poops = true
			"chaser":
				var chase_index = player.monster.state_machine.keys.find("chase")
				player.monster.state_machine.weights[chase_index] += .50
			"blocker":
				var block_index = player.monster.state_machine.keys.find("block")
				player.monster.state_machine.weights[block_index] += .50
			"attacker":
				var basic_attack_index = player.monster.state_machine.keys.find("basic_attack")
				player.monster.state_machine.weights[basic_attack_index] += .50
			"pooper":
				var other_index = player.monster.state_machine.keys.find("poop")
				player.monster.state_machine.weights[other_index] += .50
			"thorns":
				player.monster.thorns = true
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
			"larger_slimes":
				player.larger_slimes = true
			"longer_slime":
				player.longer_slimes = true
			_:
				player.monster.state_machine.state_choices[card_resource.Type].append(card_resource.state_id)
	if card_resource.remove_specific_states.size():
		for state_index in card_resource.remove_specific_states:
			player.monster.state_machine.weights[state_index] = 0
	if card_resource.unlocked_cards:
		for card in card_resource.unlocked_cards:
			player.upgrade_panel.resource_array.append(load(card.get_path()))
	if card_resource.remove_cards:
		for card in card_resource.remove_cards:
			player.upgrade_panel.resource_array.erase(card)
	if card_resource.unique:
		player.upgrade_panel.resource_array.erase(card_resource)



func apply_card_attribute(attribute, amount, player):
	match attribute:
		CardResourceScript.Attributes.HP:
			player.monster.modify_max_hp(amount)
			player.monster.modify_hp(player.monster.max_hp)
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
		upgrade_panel.reroll_button.text = "NO 🎲 LEFT"
		upgrade_panel.reroll_button.disabled = true
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
		upgrade_panel.setup_cards()
	if player.rerolls != 0 and player.upgrade_points > 0:
		var bonus_text = ""
		if player.bonus_rerolls > 0:
			#bonus_text = " Includes Bonus"
			pass
		upgrade_panel.reroll_button.text = "🎲 ALL " + "[x" + str(player.rerolls) + "]" + bonus_text
	else:
		upgrade_panel.reroll_button.text = "NO 🎲 LEFT"
		upgrade_panel.reroll_button.disabled = true

#TODO: Make a real game over scene, placeholder for playtesting
func check_if_game_over():
	if current_round >= total_rounds:
		current_mode = Modes.GAME_END
		$UpgradePanel.hide()
		print("game over")
		players.sort_custom(func(a, b): return a.victory_points > b.victory_points)
		if debug_mode:
			$Rankings.visible = true
			$Rankings.text = "Rankings:\n"
			for player in players:
				$Rankings.text += str(player.name + " (" + player.monster.mon_name + "): " + str(player.victory_points) + " points") + "\n"
		var highest_score = players[0].victory_points
		var winners = players.filter(func(p): return p.victory_points == highest_score)
		if winners.size() == 1:
			print("Winner:", winners[0].name)
			$WinnersLabel.text = "WINNER! (Press START to play again)"
			$WinnersLabel.show()
			for player in players:
				if player not in winners:
					player.get_child(0).hide()
		else:
			print("It's a tie between:")
			$WinnersLabel.text = "WINNERS! (Press START to play again)"
			$WinnersLabel.show()
			for winner in winners:
				print("- ", winner.name)
			for player in players:
				if player not in winners:
					player.get_child(0).hide()
		for player in players:
			var monster = player.get_node("Monster")
			monster.target_point = player.customize_pos

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
	add_child(poop)
	poop.add_to_group("CleanUp")


func spawn_slime(monster):
	var slime = preload("uid://upayf74ibwcl").instantiate()
	slime.monster = monster
	slime.global_position = monster.global_position + Vector2(0,30)
	if monster.player.larger_slimes:
		slime.scale += Vector2(randf_range(.50,.70), randf_range(.50,.70))
	if monster.player.longer_slimes:
		slime.lifetime = 6
	add_child(slime)
	slime.add_to_group("Slime")
	slime.add_to_group("CleanUp")


func spawn_bomb(monster):
	monster.play_generic_sound("uid://c2wiqjug8rgf4", -8.0)
	var bomb = preload("uid://gxo3acon6q5t").instantiate()
	#bomb.z_index = monster.z_index
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
	var specials = $Specials.get_children()
	var index = 0
	for player in players:
		specials[index].text = ""
		if player.monster.state_machine.special_values != []:
			specials[index].add_theme_color_override("font_outline_color", player.monster.player_color)
			specials[index].text = "Press Y: " + player.special_name
		index += 1


func _on_slime_timer_timeout():
	for player in players:
		if player.slime_trail and player.monster.current_hp > 0 and player.monster.velocity != Vector2.ZERO:
			spawn_slime(player.monster)


func add_player_node(player_number):
	var player_node : Player = Player.new()
	var monster : Monster = load("res://monster.tscn").instantiate() as Monster
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
	
