extends Node

var monster: Monster
var current_state : State
var states : Dictionary = {}
var state_choices : Dictionary = {"wander" : "wander", "chase" : "chase", "idle" : "idle", "charge_attack" : "basiccharge", "basic_attack" : "punch", "block" : "block", "other" : "pooping"}
@onready var current_state_label = $"../CurrentState"

var keys = ["wander", "chase", "idle", "charge_attack", "basic_attack", "block", "other"]
var weights = PackedFloat32Array([1,1,1,1,1,1,1])
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


# connected to "ChooseNewState" signal in state.gd
func choose_new_state():
	var new_state = keys[rng.rand_weighted(weights)]
	transition_state(state_choices[new_state])

#TODO: Scenarios for state if I want smarter creatures?
# Doesn't see a creature
# -> Wander or idle

# See a creature 
# -> if far > chase or attack
# -> if close > run away, block or attack
# -> if creature is charging up > run away or block

# connected to "Transitioned" signal in state.gd
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
