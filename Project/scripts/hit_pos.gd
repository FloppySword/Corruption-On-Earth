extends KinematicBody2D

onready var kill_timer = get_node("kill_timer")


	
func _physics_process(delta):
	delete_node()

func delete_node():

	if kill_timer.get_time_left() == 0:
		queue_free()
