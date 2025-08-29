extends State
class_name Charge

var monster: CharacterBody2D
var done_charging: bool
var charge_cycles: int
var cycle_threshold: int

func Enter():
	done_charging = false
	charge_cycles = 0
	cycle_threshold = 6
	monster.animation_player.play("charge")
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String):
	if anim_name == "charge":
		if !done_charging:
			monster.animation_player.play("charge_idle")
		else:
			# Needs to be changed to charge attack eventually
			Transitioned.emit(monster.state_machine.state_choices["basic_attack"].pick_random())
	elif anim_name == "charge_idle":
		charge_cycles += 1
		if charge_cycles >= cycle_threshold:
			monster.animation_player.play("charge", -1.0, -1.0, true)
			done_charging = true
		else:
			monster.animation_player.play("charge_idle")
