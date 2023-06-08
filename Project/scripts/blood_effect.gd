extends Area2D

var vel = Vector2()
var pos = Vector2()

onready var current_frame = get_node("current_frame")

func _ready():
	pass
	#set_process(true)
	
	
func init(pos, frame):
	global_position = pos
	#set_pos(pos)
	current_frame.set_frame(frame)
	current_frame.show()
	
func _process(delta):
	vel = Vector2(0, -300)
	global_position += vel * delta
	if global_position.y < -75:
		queue_free()
