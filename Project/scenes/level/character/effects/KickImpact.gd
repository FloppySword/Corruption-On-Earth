extends AnimatedSprite

func _initiate(pos):
	#print(pos)
	global_position = pos
	#print(global_position)
	if Global.player.global_position.x < global_position.x:
		scale.x *= -1

	frame = 0
	play("default")
	$AudioStreamPlayer.play()

	

func _on_KickImpact_animation_finished():
	queue_free()
