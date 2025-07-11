extends CharacterBody2D
class_name Monster

var max_hp : int = 3
var current_hp : int = max_hp
var base_damage : int = 1
var intelligence : int = 1
var move_speed : int = 35
var attack_speed : int = 1

var mon_name : String
var main_color
var secondary_color

@export_range(-1, 1) var hue_shift : float
@export var player : Player

@onready var state_machine = $StateMachine
@onready var hp_bar = %HPBar
@onready var current_hp_label = %current_hp
@onready var max_hp_label = %max_hp
@onready var max_health_fill_style = load("uid://b1cqxdsndopa") as StyleBox
@onready var low_health_fill_style := load("uid://dlwdv81v5y0h7") as StyleBox
@onready var animation_player : AnimationPlayer = $root/anim_player
@onready var monster_container : CanvasGroup = $root
@onready var animation_player_damage = $AnimationPlayer_Damage

@onready var body_collision = $body
var hitbox_collision
var hurtbox_collision
var hurtbox
var hitbox 

var debug_mode : bool

var target_point : Vector2

# attacks have stats: speed, mp amount, base damage, size, distance, pierce

# attacks can be short range, long range or 
# specials with a charge up
# give them preferences? melee, range, etc.

func _ready():
	current_hp_label.text = str(max_hp)
	max_hp_label.text = str(max_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	#$MonsterContainer/Parts.material.set_shader_parameter("hue_shift", hue_shift)
	generate_random_name()
	
	state_machine.monster = self

func SetCollisionRefs() -> void:
	hitbox = $root/hitbox
	hurtbox = $root/body/hurtbox
	hitbox_collision = hitbox.get_node("shape")
	hurtbox_collision = hurtbox.get_node("shape")
	
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(_delta):
	move_and_slide()
	if velocity.length() > 0 and velocity.x > 0:
		monster_container.scale = Vector2(1,1)
	if velocity.length() > 0 and velocity.x < 0:
		monster_container.scale = Vector2(-1,1)


func apply_hp(amount):
	current_hp += amount
	if current_hp >= max_hp:
		current_hp = max_hp
	if current_hp <= 0:
		current_hp = 0
	max_hp_label.text = str(max_hp)
	current_hp_label.text = str(current_hp)
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	if current_hp >= (max_hp / 3.0):
		hp_bar.add_theme_stylebox_override("fill", max_health_fill_style)


func _on_hurtbox_area_entered(area):
	if area.is_in_group("Attack") and area != hitbox:
		state_machine.transition_state("hurt")
		var attacking_mon : Node = area.get_parent().get_parent()
		var attack : String = attacking_mon.state_machine.current_state.name
		match attack.to_lower():
			"punch":
				take_damage(attacking_mon)
			"bitelifesteal":
				take_damage(attacking_mon)
				attacking_mon.apply_hp(1)


func take_damage(enemy):
	if Globals.is_sudden_death_mode:
		apply_hp(-max_hp)
	else:
		apply_hp(-enemy.base_damage)
	$Damage.text = str(enemy.base_damage)
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
	var title_start_list = ["Sir", "Madam", "Lord", "My Lady", "Baron", "Baroness", "Count", "Countess", "Duke", "Princess", "Duchess", "Emperor", "Empress", "King", "Queen", "Prince", "Dark Lord", "Archduke", "High Priest", "Commander", "Captain", "Major", "General", "Colonel", "Admiral", "Professor", "Dr.", "Reverend", "The Honorable", "Your Grace", "Warden", "Inquisitor", "Chancellor", "Vizier", "Grandmaster", "Sovereign", "Archmage", "Mystic", "The Unyielding", "Lil'", "The Gentle", "The Great", "Super"]
	var end_name_suffixes = ["Jr.", "Sr.", "II", "III", "Esq.", "PhD", "The Undying", "The Maw", "The Forsaken", "The Cute", "The Unbearable", "The Cruel", "The Worn", "The Loved", "The Joyful", "The Kind", "The Stinky", "The Opulent", "The Grim", "The Cursed", "The Faded", "The Burdened", "The Adorable", "The Weird", "The Beefy", "The Elderly", "The Bloodthirsty", "The Sexy", "The Horny", "The Terrible", "The Hideous", "The Vile", "The Cutie", "The Beefcake", "The Hunk", "The Twinkly", "The Generous", "The Gulliable", "The Handsome", "The Shitty"]
	var first_name_prefixes = ["Snuggle", "Fluffy", "Bunny", "Cuddle", "Muffin", "Puffy", "Doodle", "Wiggly", "Tootsie", "Chubby", "Fuzzy", "Wubby", "Jiggly", "Nibbles", "Boop", "Pookie", "Winky", "Bubbles", "Sprinkle", "Taffy", "Wobble", "Twirly", "Giggly", "Zippy", "Blinky", "Snoot", "Scooty", "Tater", "Tinky", "Tippy", "Mochi", "Mopsy", "Coco", "Tuggy", "Wubby", "Twinkle", "Squee", "Dizzy", "Blinky", "Nibby", "Smoosh", "Pip", "Huggy", "Binky", "Rolo", "Peachy", "Baba", "Boopsy", "Sniffy", "Derek", "Bruce", "Dan", "Tim", "Dennis", "Tushy", "Daddy", "Fabio", "Nippy", "Weenie", "Nubby", "Nub", "Batty", "Bobo", "Piggy", "Shmeckle","Lily"]
	var last_name_suffixes = ["wump", "wuff", "kins", "poo", "buns", "muff", "wubby", "wuzzy", "boo", "bean", "puff", "snug", "wiggles", "socks", "nugget", "bop", "tush", "sniff", "chub", "nubs", "flop", "snick", "pookie", "bloop", "giggles", "lumps", "floops", "tickles", "munch", "lolly", "hug", "nuzzle", "tots", "zoo", "binky", "sweetie", "nib", "toes", "twix", "peeps", "bubbles", "piddles", "gushs", "wubs", "sprig", "doodles", "noms", "bits", "squeaks", "mon", "nips", "butts", "cheeks", "frog", "shmoops", "shrimps", "prickles", "ween"]
	if randi() % 4 == 0:
		name_parts.append(title_start_list[randi() % title_start_list.size()])
	var first_name = first_name_prefixes[randi() % first_name_prefixes.size()]
	if randi() % 2 == 0:
		first_name += last_name_suffixes[randi() % last_name_suffixes.size()]
	name_parts.append(first_name)
	if randi() % 4 == 0:
		name_parts.append(end_name_suffixes[randi() % end_name_suffixes.size()])
	$Name.text = (" ".join(name_parts))

func toggle_collisions(is_enabled: bool):
	hurtbox_collision.disabled = !is_enabled
	body_collision.disabled = !is_enabled
	hitbox_collision.disabled = true
