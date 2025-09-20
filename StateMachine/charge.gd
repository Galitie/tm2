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
			# Needs to be changed to charge attack animation eventually, maybe hits a wider area?
			monster.animation_player.play("basic_attack")
			monster.velocity = Vector2.ZERO
	elif anim_name == "charge_idle":
		charge_cycles += 1
		if charge_cycles >= cycle_threshold:
			monster.animation_player.play("charge", -1.0, -1.0, true)
			done_charging = true
		else:
			monster.animation_player.play("charge_idle")
	if anim_name == "basic_attack" and done_charging:
		ChooseNewState.emit()
