extends AnimatedSprite

func _initiate(pos):
	global_position = pos
	if Global.player.global_position.x < global_position.x:
		# Flip the effect if player is to the left of the enemy
		scale.x *= -1
	frame = 0
	play("default")
	$AudioStreamPlayer.play()

func _on_KickImpact_animation_finished():
	queue_free()
