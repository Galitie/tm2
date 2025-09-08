extends State
class_name Hurt

var monster: CharacterBody2D

func Enter():
	monster.velocity = Vector2.ZERO
	monster.animation_player.play("hurt")
	
	monster.root.modulate = Color("ff0e1b")
	get_tree().create_tween().tween_property(monster.root, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_BOUNCE)

func animation_finished(anim_name: String):
	if monster.current_hp <= 0:
		Transitioned.emit("knockedout")
		return
	ChooseNewState.emit()
