extends State
class_name SpikyBlock

var monster: CharacterBody2D
var done_blocking: bool
var block_cycles: int
var block_threshold: int

func Enter():
	done_blocking = false
	block_cycles = 0
	block_threshold = 2
	monster.animation_player.play("block")
	monster.velocity = Vector2.ZERO


func animation_finished(anim_name: String):
	if anim_name == "block":
		if !done_blocking:
			monster.animation_player.play("block_idle")
		else:
			ChooseNewState.emit()
	elif anim_name == "block_idle":
		block_cycles += 1
		if block_cycles >= block_threshold:
			monster.animation_player.play("block", -1.0, -1.0, true)
			done_blocking = true
		else:
			monster.animation_player.play("block_idle")
