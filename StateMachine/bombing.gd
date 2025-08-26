extends State
class_name Bombing

var monster: CharacterBody2D

var done_charging: bool
var charge_cycles: int
var cycle_threshold: int

signal spawn_bomb(monster)

func Enter():
	done_charging = false
	charge_cycles = 0
	cycle_threshold = 1
	monster.animation_player.play("charge")
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String):
	if anim_name == "charge":
		if !done_charging:
			monster.animation_player.play("charge_idle")
		else:
			emit_signal("spawn_bomb", monster) # Caught in main game scene
			ChooseNewState.emit() 
	
	elif anim_name == "charge_idle":
		charge_cycles += 1
		if charge_cycles >= cycle_threshold:
			monster.animation_player.play("charge", -1.0, -1.0, true)
			done_charging = true
		else:
			monster.animation_player.play("charge_idle")
