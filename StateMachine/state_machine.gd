extends Node

var monster: Monster
var current_state : State
var states : Dictionary = {}
@onready var current_state_label = $"../CurrentState"


var keys = ["wander", "chase", "idle", "charge_attack", "basic_attack", "block", "poop", "special"]
var weights = PackedFloat32Array([1,1.75,1,1,1,1,1,0])

# Starting deck
var wander_values = ["wander"]
var chase_values = ["chase"]
var idle_values = ["idle"]
var charge_attack_values = ["basiccharge"]
var basic_attack_values = ["punch"]
var block_values = ["block"]
var poop_values = ["pooping"]
var special_values = []

var state_choices : Dictionary = {"wander" : wander_values, "chase" : chase_values, "idle" : idle_values, "charge_attack" : charge_attack_values, "basic_attack" : basic_attack_values, "block" : block_values, "poop" : poop_values, "special" : special_values}

var rng = RandomNumberGenerator.new()

func initialize():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(transition_state)
			child.ChooseNewState.connect(choose_new_state)
			child.monster = monster
	states["idle"].Enter()
	current_state = states["idle"]
	monster.animation_player.animation_finished.connect(_animation_finished)


func _process(delta):
	if current_state:
		current_state.Update(delta)


func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)


# connected to "ChooseNewState" signal in state.gd, transitions to a state collection
func choose_new_state(specific_state : String = ""):
	if specific_state == "":
		var new_state : String = keys[rng.rand_weighted(weights)] #randmly choose their next state collection
		transition_state(state_choices[new_state].pick_random())
		return
	transition_state(state_choices[specific_state].pick_random())

# connected to "Transitioned" signal in state.gd, transitions to specific state node, not collection
func transition_state(new_state_name):
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	current_state.Exit()
	current_state = new_state
	current_state.Enter()
	if monster.debug_mode:
		current_state_label.text = current_state.name


func _animation_finished(anim_name: String) -> void:
	current_state.animation_finished(anim_name)

func use_special():
	if special_values != [] and monster.current_hp > 0:
		choose_new_state("special")
