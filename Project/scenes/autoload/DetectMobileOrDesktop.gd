extends Node

signal detected

func _input(event):
	if event.device == -1:
		Global.device = "Mobile"
		print("MOBILE DEVICE DETECTED")
		#emit_signal("detected")
		queue_free()
		
		
		
		
#	else:
#		$Timer.start()
#
#func _PC_detected():
#	Global.device = "PC"
#	emit_signal("detected")
#	queue_free()
##		else:
##			Global.device = "PC"

	
#	return
#	if event is InputEventScreenTouch:
#		Global.device = "Mobile"
#		emit_signal("detected")
#		queue_free()
#	if (event is InputEventKey && event.scancode == KEY_ENTER) \
#	|| event is InputEventMouseMotion:
#		Global.device = "PC"
#		emit_signal("detected")
#		print(Global.device)
#		queue_free()


#func _on_Timer_timeout():
#	if Global.device == "PC":
#		$Timer.start()
#	else:
#		Global.device = "Mobile"
#		emit_signal("detected")
#		queue_free()
