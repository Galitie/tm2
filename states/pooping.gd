extends State
class_name Pooping

var monster: CharacterBody2D

var done_charging: bool
var charge_cycles: int
var cycle_threshold: int

signal spawn_poop(monster)

func Enter():
	done_charging = false
	charge_cycles = 0
	cycle_threshold = 3
	monster.animation_player.play("poop")
	monster.play_generic_sound("uid://hth28y5uoru0", -2)
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String):
	if anim_name == "poop":
		if !done_charging:
			monster.animation_player.play("poop_idle")
		else:
			emit_signal("spawn_poop", monster) # Caught in main game scene
			if monster.player.more_poops and randi() % 2 == 0:
				emit_signal("spawn_poop", monster) # Caught in main game scene
			ChooseNewState.emit() 
	
	elif anim_name == "poop_idle":
		charge_cycles += 1
		if charge_cycles >= cycle_threshold:
			monster.animation_player.play("poop", -1.0, -1.0, true)
			done_charging = true
		else:
			monster.animation_player.play("poop_idle")
