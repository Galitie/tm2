extends CharacterBody2D
class_name Monster

var max_hp : int = 10
var current_hp : int = max_hp
var base_damage : int = 1
var intelligence : int = 1
var move_speed : int = 35
var attack_speed : int = 1
var crit_chance: int = 1
var crit_multiplier: float = 1.5
var damage_received_mult: float = 1.0
var damage_dealt_mult: float = 1.0
var thorns : bool = false

var mon_name : String
var main_color

@export_range(-1, 1) var hue_shift : float
@export var player : Player

@onready var root = $root
@onready var state_machine = $StateMachine
@onready var hp_bar = %HPBar
@onready var current_hp_label = %current_hp
@onready var max_hp_label = %max_hp
@onready var max_health_fill_style = load("uid://b1cqxdsndopa") as StyleBox
@onready var low_health_fill_style := load("uid://dlwdv81v5y0h7") as StyleBox
@onready var animation_player : AnimationPlayer = $root/anim_player
@onready var monster_container : CanvasGroup = $root
@onready var animation_player_damage = $AnimationPlayer_Damage

@onready var poop_checker = $root/PoopChecker
@onready var body_collision = $body

@onready var audio_player = $AudioStreamPlayer

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

var base_color: Color
var secondary_color: Color

# attacks have stats: speed, mp amount, base damage, size, distance, pierce

# attacks can be short range, long range or 
# specials with a charge up
# give them preferences? melee, range, etc.

func _ready():
	add_to_group("DepthEntity")
	
	current_hp_label.text = str(max_hp)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	#$MonsterContainer/Parts.material.set_shader_parameter("hue_shift", hue_shift)
	generate_random_name()
	state_machine.monster = self
	
	base_color = Color(randf_range(0.5, 1), randf_range(0.5, 1), randf_range(0.5, 1))
	secondary_color = Color(randf_range(0.5, 1), randf_range(0.5, 1), randf_range(0.5, 1))


func SetCollisionRefs() -> void:
	hitbox = $root/hitbox
	hurtbox = $root/BODY/hurtbox
	hitbox_collision = hitbox.get_node("shape")
	hurtbox_collision = hurtbox.get_node("shape")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)


func _physics_process(_delta):
	move_and_slide()
	if velocity.length() > 0 and velocity.x > 0:
		monster_container.scale = Vector2(1,1)
		facing = "right"
	if velocity.length() > 0 and velocity.x < 0:
		monster_container.scale = Vector2(-1,1)
		facing = "left"
		
	var line_thickness: float = 4.0 * Globals.game.camera.zoom.x
	root.material.set_shader_parameter("line_thickness", line_thickness)


func apply_hp(amount):
	if amount < 0:
		$Damage.text = str(abs(amount))
		animation_player_damage.play("damage")
	current_hp += amount
	if current_hp >= max_hp:
		current_hp = max_hp
	if current_hp <= 0:
		current_hp = 0
	max_hp_label.text = str(max_hp)
	current_hp_label.text = str(current_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	check_low_hp()
	if current_hp >= (max_hp / 3.0):
		hp_bar.add_theme_stylebox_override("fill", max_health_fill_style)

# Hurt logic should be in take_damage_from, not this collision function
func _on_hurtbox_area_entered(area):
	var attacker: Node
	attacked = false
	if area != hitbox:
		var current_state = state_machine.current_state.name.to_lower()
		var area_that_can_damage : bool = area.is_in_group("Attack") or area.is_in_group("Projectile") or area.is_in_group("Bomb")
		if current_state.contains("block") and area_that_can_damage:
			attacker = area.get_parent().get_parent()
			match current_state.to_lower():
				"spikyblock":
					if attacker == Monster:
						attacker.take_damage_from(attacker)
						attacker.state_machine.transition_state("hurt")
					return
				_:
					return
		if area.is_in_group("Attack"):
			attacked = true
			attacker = area.get_parent().get_parent()
			var attack : String = attacker.state_machine.current_state.name
			match attack.to_lower():
				"punch":
					take_damage_from(attacker)
				"bitelifesteal":
					take_damage_from(attacker)
					attacker.apply_hp(3)
			if thorns:
				attacker.attacked = true
				attacker.take_damage_from(self, 1)
				attacker.state_machine.transition_state("hurt")
				# Because of current logic, the attacker is knocked out first, so they lose
				# the tie in sudden death
				if Globals.is_sudden_death_mode:
					attacker.send_flying(attacker)
			state_machine.transition_state("hurt")
		if area.is_in_group("Projectile") and area.owner.monster != self:
			attacked = true
			attacker = area.owner.emitter
			take_damage_from(attacker)
			state_machine.transition_state("hurt")
		if area.is_in_group("Bomb"):
			attacked = true
			attacker = area.owner
			take_damage_from(attacker)
			state_machine.transition_state("hurt")

	if attacked && Globals.is_sudden_death_mode:
		send_flying(attacker)


func send_flying(attacker: Node) -> void:
	sent_flying = true
	state_machine.transition_state("knockedout")
	audio_player.play()
	
	knockback = (global_position - attacker.global_position).normalized().x
	Globals.game.freeze_frame(self)

func take_damage_from(enemy, override_damage: int = 0):
	var critted = roll_crit()
	var crit_text = " CRIT" if critted else ""
	var random_modifier : int = randi_range(0,3)
	var damage : int = round(enemy.base_damage * (enemy.crit_multiplier if critted else 1.0) * enemy.damage_dealt_mult) + random_modifier
	if override_damage:
		damage = override_damage
	if Globals.is_sudden_death_mode:
		apply_hp(-max_hp)
	else:
		apply_hp(-damage * damage_received_mult)
	$Damage.text = str(damage) + crit_text
	animation_player_damage.play("damage")
	check_low_hp()


func check_low_hp():
	if current_hp <= (max_hp / 3.0):
		hp_bar.add_theme_stylebox_override("fill", low_health_fill_style)


func update_slot(current_slot_id : String, replacement_slot_id : String):
	state_machine.state_choices.erase(current_slot_id)
	state_machine.state_choices.append(replacement_slot_id)


func generate_random_name():
	var name_parts = []
	var title_start_list = ["Sir", "Madam", "Lord", "My Lady", "Baron", "Baroness", "Count", "Countess", "Duke", "Princess", "Duchess", "Emperor", "Empress", "King", "Queen", "Prince", "Dark Lord", "Archduke", "High Priest", "Commander", "Captain", "Major", "General", "Colonel", "Admiral", "Professor", "Dr.", "Reverend", "The Honorable", "Your Grace", "Warden", "Inquisitor", "Chancellor", "Vizier", "Grandmaster", "Sovereign", "Archmage", "Mystic", "The Unyielding", "Lil'", "The Gentle", "The Great", "Super", "O'" ]
	var first_name_prefixes = ["Snuggle", "Fluffy", "Bunny", "Cuddle", "Muffin", "Puffy", "Doodle", "Wiggly", "Tootsie", "Chubby", "Fuzzy", "Wubby", "Jiggly", "Nibbles", "Boop", "Pookie", "Winky", "Bubbles", "Sprinkle", "Taffy", "Wobble", "Twirly", "Giggly", "Zippy", "Blinky", "Snoot", "Scooty", "Tater", "Tinky", "Tippy", "Mochi", "Mopsy", "Coco", "Tuggy", "Wubby", "Twinkle", "Squee", "Dizzy", "Blinky", "Nibby", "Smoosh", "Pip", "Huggy", "Binky", "Rolo", "Peachy", "Baba", "Boopsy", "Sniffy", "Derek", "Bruce", "Dan", "Tim", "Dennis", "Tushy", "Daddy", "Fabio", "Nippy", "Weenie", "Nubby", "Nub", "Batty", "Bobo", "Piggy", "Shmeckle","Lily", "Dale", "Egg", "Humpy", "Mac", "Fitz", "Von", "Van"]
	var last_name_suffixes = ["wump", "humps" , "wuff", "kins", "poo", "buns", "muff", "wubby", "wuzzy", "boo", "bean", "puff", "snug", "wiggles", "socks", "nugget", "bop", "tush", "sniff", "chub", "nubs", "flop", "snick", "pookie", "bloop", "giggles", "lumps", "floops", "tickles", "munch", "lolly", "hug", "nuzzle", "tots", "zoo", "binky", "sweetie", "nib", "toes", "twix", "peeps", "bubbles", "piddles", "gushs", "wubs", "sprig", "doodles", "noms", "bits", "squeaks", "mon", "nips", "butts", "cheeks", "frog", "shmoops", "shrimps", "prickles", "ween", "burt", "smeeks", "licky", "wax", "pops", "nops", "tits"]
	var end_name_suffixes = ["Jr.", "Sr.", "II", "III", "Esq.", "PhD", "The Undying", "The Maw", "The Forsaken", "The Cute", "The Unbearable", "The Cruel", "The Worn", "The Loved", "The Joyful", "The Kind", "The Stinky", "The Opulent", "The Grim", "The Cursed", "The Faded", "The Burdened", "The Adorable", "The Weird", "The Beefy", "The Elderly", "The Bloodthirsty", "The Sexy", "The Horny", "The Terrible", "The Hideous", "The Vile", "The Cutie", "The Beefcake", "The Hunk", "The Twinkly", "The Generous", "The Gulliable", "The Handsome", "The Shitty", "The Dark", "of Fuckshire", "of Yore", "of Legend", "The Wicked", "The Fabulous"]
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
	mon_name = whole_name

func toggle_collisions(is_enabled: bool):
	hurtbox_collision.set_deferred("disabled", !is_enabled)
	body_collision.set_deferred("disabled", !is_enabled)
	hitbox_collision.set_deferred("disabled", true)


func roll_crit() -> bool:
	var chance = randi_range(1,100)
	if crit_chance >= chance:
		return true
	return false
