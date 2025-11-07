extends State
class_name Hurt

var monster: CharacterBody2D

func Enter():
	monster.velocity = Vector2.ZERO
	monster.animation_player.play("hurt")


func animation_finished(anim_name: String):
	#if monster.current_hp <= 0:
		#Transitioned.emit("knockedout")
		#return
	if monster.player.poop_on_hit:
		var rand = [0,1].pick_random()
		if rand:
			ChooseNewState.emit("poop")
			return
	ChooseNewState.emit()
