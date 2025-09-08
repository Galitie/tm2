extends State
class_name Hurt

var monster: CharacterBody2D

func Enter():
	monster.velocity = Vector2.ZERO
	monster.animation_player.play("hurt")
	
	monster.get_node("root").modulate = Color.RED
	get_tree().create_tween().tween_property(monster.get_node("root"), "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_BOUNCE)

func animation_finished(anim_name: String):
	if monster.current_hp <= 0:
		Transitioned.emit("knockedout")
		return
	ChooseNewState.emit()
