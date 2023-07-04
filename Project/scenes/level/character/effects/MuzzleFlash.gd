extends Sprite

func _initiate(dir, pos):
	global_rotation = dir
	global_position = pos


func _on_Timer_timeout():
	# Timer autostarted.
	queue_free()
