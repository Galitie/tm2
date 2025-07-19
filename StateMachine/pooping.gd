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
	monster.animation_player.play("charge")
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String):
	if anim_name == "charge":
		if !done_charging:
			monster.animation_player.play("charge_idle")
		else:
			# Make sure poops don't spawn on each other and freak out
			var bodies : Array[Node2D] = monster.poop_checker.get_overlapping_bodies()
			for body in bodies:
				if body is Poop:
					print("found some poop, did it fly?")
					var difference = monster.poop_checker.global_position - body.global_position
					var direction = difference.normalized()
					var circle_radius = 15.52
					var penetration = direction * circle_radius
					body.velocity += -penetration * 0.5
			emit_signal("spawn_poop", monster) # Caught in main game scene
			if monster.player.more_poops and randi() % 2 == 0:
				print("pooped twice!")
				bodies = monster.poop_checker.get_overlapping_bodies()
				for body in bodies:
					if body is Poop:
						print("found some poop, did it fly?")
						var difference = monster.poop_checker.global_position - body.global_position
						var direction = difference.normalized()
						var circle_radius = 15.52
						var penetration = direction * circle_radius
						body.velocity += -penetration * 0.5
				emit_signal("spawn_poop", monster) # Caught in main game scene
			ChooseNewState.emit() 
	
	elif anim_name == "charge_idle":
		charge_cycles += 1
		if charge_cycles >= cycle_threshold:
			monster.animation_player.play("charge", -1.0, -1.0, true)
			done_charging = true
		else:
			monster.animation_player.play("charge_idle")
