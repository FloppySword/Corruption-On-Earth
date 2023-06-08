extends Sprite

func _ready():
	set_process(true)

func init(dir, pos):
	global_rotation =dir# -dir + PI
	global_position = pos

	

	

func _on_Timer_timeout():
	queue_free()
