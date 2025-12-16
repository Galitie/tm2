extends State
class_name UpgradeIdle

var monster: CharacterBody2D




func Enter():
	monster.animation_player.play("idle")
	

func animation_finished(anim_name: String):
	if anim_name == "upgrade_react":
		monster.animation_player.play("idle")
