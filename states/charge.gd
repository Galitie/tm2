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
	monster.play_generic_sound("uid://dhufls6y0ive3", -1)
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String):
	if anim_name == "charge":
		if !done_charging:
			monster.animation_player.play("charge_idle")
		else:
			ChooseNewState.emit("basic_attack") #TODO: this should be it's own attack eventually?
			
	elif anim_name == "charge_idle":
		charge_cycles += 1
		if charge_cycles >= cycle_threshold:
			monster.animation_player.play("charge", -1.0, -1.0, true)
			done_charging = true
		else:
			monster.animation_player.play("charge_idle")
