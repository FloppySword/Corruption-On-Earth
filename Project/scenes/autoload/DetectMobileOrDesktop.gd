extends Node

# This autoload scene is essentially a listener to determine the device type.
# As soon as an input is detected, it determines the device, sets the Global
# variable, and queues free. 

func _input(event):
	if event.device == -1:
		Global.device = "Mobile"
		queue_free()
