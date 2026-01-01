extends State
class_name Block

var monster: CharacterBody2D
var done_blocking: bool
var block_cycles: int
var block_threshold: int

func Enter():
	done_blocking = false
	block_cycles = 0
	monster.play_generic_sound("uid://0pyjmjp6rvg7")
	if monster.player.block_longer:
		block_threshold = 4.5
	else:
		block_threshold = 2.5
	monster.animation_player.play("block")
	monster.velocity = Vector2.ZERO
	
	monster.toggle_effect_graphic(true, Monster.EffectType.BLOCK)


func Exit():
	monster.toggle_effect_graphic(false)


func animation_finished(anim_name: String):
	if anim_name == "block":
		if !done_blocking:
			monster.animation_player.play("block_idle")
			#monster.hurtbox_collision.disabled = true
		else:
			ChooseNewState.emit()
	elif anim_name == "block_idle":
		block_cycles += 1
		if block_cycles >= block_threshold:
			monster.animation_player.play("block", -1.0, -1.0, true)
			done_blocking = true
		else:
			monster.animation_player.play("block_idle")
