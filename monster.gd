extends CharacterBody2D
class_name Monster

var max_hp : int = 3
var current_hp : int = max_hp
var base_damage : int = 1
var intelligence : int = 1
var move_speed : int = 50
var attack_speed : int = 1
var crit_chance: int = 1
var crit_multiplier: float = 1.5
var damage_received_mult: float = 1.0
var damage_dealt_mult: float = 1.0
var thorns : bool = false
enum attack_type {NONE, MONSTER, BOMB, PROJECTILE, THORN, SLIME}

var mon_name : String
@onready var name_label = $Name

var player : Player

@onready var root = $root
@onready var state_machine = $StateMachine
@onready var hp_bar = %HPBar
@onready var current_hp_label = %current_hp
@onready var max_hp_label = %max_hp
@onready var animation_player : AnimationPlayer = $root/anim_player
@onready var animation_player_damage = $AnimationPlayer_Damage
@onready var animation_player_heal = $AnimationPlayer_Heal
@onready var heal_label = $Heal
@onready var health_texture : Texture = load("res://UI/health.png")
@onready var low_health_texture : Texture = load("res://UI/health_low.png")
@onready var poop_checker = $root/PoopChecker
@onready var body_collision = $body_collision
@onready var slime_timer = $SlimeTimer
@onready var audio_player = $AudioStreamPlayer

var block_texture = load("uid://bn3ju1wjp60ea")
var mirror_block_texture = load("uid://ck7a7uoebctrw")
var thorns_texture = load("uid://mbp3wn4a84i6")

var hitbox_collision
var hurtbox_collision
var hurtbox
var hitbox 
var attacked : bool = false

var sent_flying: bool = false
var knockback: float

var debug_mode : bool
@export var pre_loaded_cards : Array[Resource]
var facing : String = "right"
var target_point : Vector2

@export var player_color: Color
var mod_color: Color = Color.TRANSPARENT

#TODO: Raam, temp stuff for explode on death
var temp_timer = Timer.new()
var temp_area = Area2D.new()

func _ready():
	add_to_group("DepthEntity")
	
	current_hp_label.text = str(max_hp)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	#$MonsterContainer/Parts.material.set_shader_parameter("hue_shift", hue_shift)
	generate_random_name()
	state_machine.monster = self
	
	root.material.set_shader_parameter("outer_color", player_color)


func SetCollisionRefs() -> void:
	hitbox = $root/hitbox
	hurtbox = $root/BODY/hurtbox
	hitbox_collision = hitbox.get_node("shape")
	hurtbox_collision = hurtbox.get_node("shape")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)


func _physics_process(_delta):
	move_and_slide()
	var s: Vector2 = root.scale
	if velocity.length() > 0 and velocity.x > 0:
		s.x = abs(s.x)
		facing = "right"
	if velocity.length() > 0 and velocity.x < 0:
		s.x = -abs(s.x) 
		facing = "left"
	root.scale = s


func _on_hurtbox_area_entered(area):
	var attacker: Node
	if area != hitbox:
		var current_state = state_machine.current_state.name.to_lower()

		if current_state.contains("block"):
			attacker = area.get_parent().get_parent()
			if (area.is_in_group("Projectile") or area.is_in_group("Slime")) and area.owner.monster == self:
				return
			take_damage(attacker, current_state, true)
			return
	
		elif area.is_in_group("Attack"):
			attacker = area.get_parent().get_parent()
			take_damage(attacker, current_state, false, attack_type.MONSTER)

		elif area.is_in_group("Projectile") and area.owner.monster != self: #don't shoot self
			attacker = area.owner.emitter
			if player.matrix:
				var rand = [1,2].pick_random()
				if rand == 1:
					take_damage(null, current_state, true, attack_type.PROJECTILE)
				else:
					play_generic_sound("uid://cf8aw1xy3pg34")
					mod_monster(Color("3467ff"))
					get_tree().create_tween().tween_method(mod_monster, Color("3467ff"), mod_color, 1).set_trans(Tween.TRANS_CUBIC)
					return
			else:
				take_damage(null, current_state, true, attack_type.PROJECTILE)
				
		elif area.is_in_group("Bomb"):
			take_damage(attacker, current_state, true, attack_type.BOMB)
		
		elif area.is_in_group("Slime") and area.owner.monster != self:
			take_damage(area.owner, current_state, true, attack_type.SLIME)


func take_damage(attacker = null, current_state : String = "", ignore_crit: bool = false, type : attack_type = attack_type.NONE, override_damage : int = 0):
	var damage : int
	var critted : bool
	var crit_text : String
	var mod_text : String
	var random_modifier : int
	if current_state.contains("block"):
		match current_state.to_lower():
			"mirrorblock":
				if attacker is Monster:
					var attacker_state = attacker.state_machine.current_state.name.to_lower()
					attacker.take_damage(attacker, attacker_state, false, attack_type.MONSTER)
		play_generic_sound("uid://cf8aw1xy3pg34")
		mod_monster(Color("3467ff"))
		get_tree().create_tween().tween_method(mod_monster, Color("3467ff"), mod_color, 1).set_trans(Tween.TRANS_CUBIC)
		return
	if type == attack_type.MONSTER:
		var attack : String = attacker.state_machine.current_state.name
		match attack.to_lower():
			"bitelifesteal":
				attacker.modify_hp(max_hp)
				attacker.heal_label.text = "HEAL MAX HP"
				attacker.animation_player_heal.play("heal")
		if thorns:
			var attacker_state = attacker.state_machine.current_state.name.to_lower()
			attacker.take_damage(self, attacker_state, false, attack_type.THORN)
		critted = roll_crit()
		crit_text = " CRIT" if critted && !ignore_crit else ""
		random_modifier = randi_range(0,3)
		damage = round(attacker.base_damage * (attacker.crit_multiplier if critted else 1.0) * attacker.damage_dealt_mult * damage_received_mult) + random_modifier 
		if damage == 0:
			damage = 1
		modify_hp(-(damage))
	elif type == attack_type.THORN:
		damage = 1
		mod_text = " THORN"
		modify_hp(-damage)
		thorn_effect()
	elif type == attack_type.BOMB:
		random_modifier = randi_range(0,5)
		damage = round(10 + random_modifier)
		modify_hp(-damage)
	elif type == attack_type.PROJECTILE:
		random_modifier = randi_range(1,5)
		damage = random_modifier
		modify_hp(-damage)
	elif type == attack_type.SLIME:
		damage = 1
		mod_text = " SLIME"
		modify_hp(-damage)
	if override_damage:
		modify_hp(-override_damage)
		damage = override_damage
	if Globals.is_sudden_death_mode:
		modify_hp(-max_hp)
	$Damage.text = str(int(damage)) + crit_text + mod_text
	animation_player_damage.play("damage")
	hit_effect(critted)
	state_machine.transition_state("hurt")
	if current_hp <= 0:
		if player.zombie and !player.revived:
			zombify()
			return
		toggle_collisions(false)
		Globals.game.count_death(self)
		if Globals.is_sudden_death_mode:
			send_flying(attacker)
		elif player.death_explode:
			explode_on_death()


#TODO: Raam explosion animation???
func explode_on_death():
	temp_area = Area2D.new()
	var temp_collision = CollisionShape2D.new()
	var temp_shape_resource = CircleShape2D.new()
	var temp_sprite = Sprite2D.new()
	temp_sprite.texture = load("uid://cgrc4jxdyeooy")
	temp_sprite.scale = Vector2(3,3)
	temp_shape_resource.radius = hurtbox_collision.shape.size.x * 1.50
	temp_collision.shape = temp_shape_resource
	temp_area.add_to_group("Bomb")
	temp_area.add_to_group("CleanUp")
	temp_area.add_child(temp_collision)
	temp_timer = Timer.new()
	temp_timer.timeout.connect(_on_temp_timer_timeout)
	temp_area.add_child(temp_sprite)
	temp_area.add_child(temp_timer)
	temp_timer.wait_time = .40
	temp_timer.autostart = true
	call_deferred("add_child", temp_area)
	


#TODO: Raam explosion animation???
func _on_temp_timer_timeout():
	if temp_area != null:
		temp_area.queue_free()


func zombify():
	state_machine.transition_state("zombie")
	toggle_collisions(false)
	modify_hp(1)
	$ZombieTimer.start()


func unzombify():
	player.revived = false
	mod_color = Color.TRANSPARENT
	mod_monster(mod_color)


func _on_zombie_timer_timeout():
	play_generic_sound("uid://s01jaub4gq8s")
	player.revived = true
	$Heal.text = "+1 HP ZOMBIE"
	animation_player_heal.play("heal")
	toggle_collisions(true)
	if Globals.game.current_mode != Globals.game.Modes.UPGRADE:
		state_machine.transition_state("getupandgo")
		mod_color = Color(0.0, 0.39, 0.0, 0.7)
		mod_monster(mod_color)
	else:
		state_machine.transition_state("upgradestart")


func modify_hp(amount):
	current_hp = clamp(current_hp + amount, 0, max_hp)
	current_hp_label.text = str(current_hp)
	hp_bar.value = current_hp
	update_hp_color()


func modify_max_hp(amount):
	max_hp = clamp(max_hp + amount, 1, 1000)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp


func hit_effect(crit: bool = false) -> void:
	if crit:
		play_generic_sound("uid://dfjgpdho3lcvd", -5.0)
	else:
		play_generic_sound("uid://djhtlpq02uk4n", -5.0)
	mod_monster(Color("ff0e1b"))
	get_tree().create_tween().tween_method(mod_monster, Color("ff0e1b"), mod_color, 1).set_trans(Tween.TRANS_CUBIC)


func mod_monster(color: Color) -> void:
	MonsterGeneration.ModulateMonster(self, color)


func play_generic_sound(uid: String, volume_db: float = 0.0) -> void:
	audio_player.stream = load(uid)
	audio_player.pitch_scale = randf_range(0.8, 1.2)
	audio_player.volume_db = volume_db
	audio_player.play()
	await audio_player.finished
	audio_player.pitch_scale = 1.0


func thorn_effect() -> void:
	play_generic_sound("uid://can2y656sbycd", -5.0)
	mod_monster(Color("6bff7d"))
	get_tree().create_tween().tween_method(mod_monster, Color("6bff7d"), mod_color, 1).set_trans(Tween.TRANS_CUBIC)
	toggle_effect_graphic(true, EffectType.THORNS)
	await get_tree().create_timer(0.5).timeout
	toggle_effect_graphic(false)

func send_flying(attacker: Node) -> void:
	mod_monster(Color("ff0e1b"))
	sent_flying = true
	state_machine.transition_state("knockedout")
	audio_player.pitch_scale = 1.0
	audio_player.stream = load("uid://dfjgpdho3lcvd")
	audio_player.play()
	var attacker_position: Vector2
	if attacker != null:
		attacker_position = attacker.global_position
	else:
		attacker_position = global_position
	knockback = (global_position - attacker_position).normalized().x
	Globals.game.freeze_frame(self)


func update_hp_color():
	if current_hp <= (max_hp / 3.0):
		$HPBar.texture_progress = low_health_texture
	else:
		$HPBar.texture_progress = health_texture


func move_name_upgrade():
	$NameUpgrade.visible = true
	$Name.visible = false


func move_name_fight():
	$NameUpgrade.visible = false
	$Name.visible = true


func toggle_collisions(is_enabled: bool):
	hurtbox_collision.set_deferred("disabled", !is_enabled)
	body_collision.set_deferred("disabled", !is_enabled)
	hitbox_collision.set_deferred("disabled", true)


func roll_crit() -> bool:
	var chance = randi_range(1,100)
	if crit_chance >= chance:
		return true
	return false


func generate_random_name():
	var name_parts = []
	var title_start_list = ["Sir", "Madam", "Lord", "My Lady", "Baron", "Baroness", "Count", "Countess", "Duke", "Princess", "Duchess", "Emperor", "Empress", "King", "Queen", "Prince", "Dark Lord", "Archduke", "High Priest", "Commander", "Captain", "Major", "General", "Colonel", "Admiral", "Professor", "Dr.", "Reverend", "The Honorable", "Your Grace", "Warden", "Inquisitor", "Chancellor", "Vizier", "Grandmaster", "Sovereign", "Archmage", "Mystic", "The Unyielding", "Lil'", "The Gentle", "The Great", "Super", "O'", "Dear", "Darling", "Mega", "Champion", "Mr.", "Miss", "Dame", "Overlord", "Warlord", "Sheriff", "President", "Prof."]
	var first_name_prefixes = ["Scooby", "Snuggle", "Fluffy", "Bunny", "Cuddle", "Muffin", "Puffy", "Doodle", "Wiggly", "Tootsie", "Chubby", "Fuzzy", "Wubby", "Jiggly", "Nibbles", "Boop", "Pookie", "Winky", "Bubbles", "Sprinkle", "Taffy", "Wobble", "Twirly", "Giggly", "Zippy", "Blinky", "Snoot", "Scooty", "Tater", "Tinky", "Tippy", "Mochi", "Mopsy", "Coco", "Tuggy", "Wubby", "Twinkle", "Squee", "Dizzy", "Blinky", "Nibby", "Smoosh", "Pip", "Huggy", "Binky", "Rolo", "Peachy", "Baba", "Boopsy", "Sniffy", "Derek", "Bruce", "Dan", "Tim", "Dennis", "Tushy", "Daddy", "Fabio", "Nippy", "Weenie", "Nubby", "Nub", "Batty", "Bobo", "Piggy", "Shmeckle","Lily", "Dale", "Egg", "Humpy", "Mac", "Fitz", "Von", "Van", "Pickle", "Baby", "Sabun", "Goober", "Gob", "Robo", "Niblet", "Bongo", "Noodle", "Spooky", "Batty", "Drago", "Peepee", "Digi"]
	var last_name_suffixes = ["roo","wump", "humps" , "wuff", "kins", "poo", "buns", "muff", "wubby", "wuzzy", "boo", "bean", "puff", "snug", "wiggles", "socks", "nugget", "bop", "tush", "sniff", "chub", "nubs", "flop", "snick", "pookie", "bloop", "giggles", "lumps", "floops", "tickles", "munch", "lolly", "hug", "nuzzle", "tots", "zoo", "binky", "sweetie", "nib", "toes", "twix", "peeps", "bubbles", "piddles", "gushs", "wubs", "sprig", "doodles", "noms", "bits", "squeaks", "mon", "nips", "butts", "cheeks", "frog", "shmoops", "shrimps", "prickles", "ween", "burt", "smeeks", "licky", "wax", "pops", "nops", "tits", "shnicky", "hots", "shits", "dicks", "poopsy", "poops", "pug", "pips", "legs", "vicky", "goobs", "goober", "bats", "balls", "lops"]
	var end_name_suffixes = ["Jr.", "Sr.", "II", "III", "Esq.", "PhD", "The Undying", "The Maw", "The Forsaken", "The Cute", "The Unbearable", "The Cruel", "The Worn", "The Loved", "The Joyful", "The Kind", "The Stinky", "The Opulent", "The Grim", "The Cursed", "The Faded", "The Burdened", "The Adorable", "The Weird", "The Beefy", "The Elderly", "The Bloodthirsty", "The Sexy", "The Horny", "The Terrible", "The Hideous", "The Vile", "The Cutie", "The Beefcake", "The Hunk", "The Twinkly", "The Generous", "The Gulliable", "The Handsome", "The Shitty", "The Dark", "of Fuckshire", "of Yore", "of Legend", "The Wicked", "The Fabulous", "The Baby", "The Ghastly", "The Timid", "The Hunk", "The Poopy", "The Godly", "The Shafted", "The Treasure", "V", "MD", "The Mighty", "of Chaos", "of Shadows", "The Cringe", "The Creep", "of Tinkles", "The White", "The Grey"]
	if randi() % 4 == 0:
		name_parts.append(title_start_list[randi() % title_start_list.size()])
	var first_name = first_name_prefixes[randi() % first_name_prefixes.size()]
	if randi() % 2 == 0:
		first_name += last_name_suffixes[randi() % last_name_suffixes.size()]
	name_parts.append(first_name)
	if randi() % 4 == 0:
		name_parts.append(end_name_suffixes[randi() % end_name_suffixes.size()])
	var whole_name: String =  " ".join(name_parts)
	$Name.text = whole_name
	$NameUpgrade.text = whole_name
	mon_name = whole_name

enum EffectType { BLOCK, MIRROR_BLOCK, THORNS }

func toggle_effect_graphic(toggle: bool, type: EffectType = EffectType.BLOCK) -> void:
	var effect_sprite: Sprite2D = $effect
	
	if (toggle):
		match type:
			EffectType.BLOCK:
				effect_sprite.texture = block_texture
			EffectType.MIRROR_BLOCK:
				effect_sprite.texture = mirror_block_texture
			EffectType.THORNS:
				effect_sprite.texture = thorns_texture
	
	effect_sprite.z_index = z_index + 1
	
	if toggle:
		effect_sprite.modulate = Color.TRANSPARENT
		effect_sprite.visible = true
		get_tree().create_tween().tween_property(effect_sprite, "modulate", Color.WHITE, 0.25)
	else:
		await get_tree().create_tween().tween_property(effect_sprite, "modulate", Color.TRANSPARENT, 0.25).finished
		effect_sprite.visible = false

func _on_slime_timer_timeout():
	if player.slime_trail and current_hp > 0 and velocity != Vector2.ZERO:
		spawn_slime()


func spawn_slime():
	var slime = preload("uid://upayf74ibwcl").instantiate()
	slime.monster = self
	slime.global_position = global_position + Vector2(0,30)
	if player.larger_slimes:
		slime.scale += Vector2(randf_range(.50,.70), randf_range(.50,.70))
	if player.longer_slimes:
		slime.lifetime = 6
	get_tree().get_root().get_node("Game").add_child(slime)
	slime.add_to_group("Slime")
	slime.add_to_group("CleanUp")
