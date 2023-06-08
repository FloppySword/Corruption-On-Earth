extends KinematicBody2D

onready var selector = get_node("selector")

var pos = Vector2()
var vel = Vector2(0, -300)

func init(randx):
	if randx >= 1190:
		randx = 1180
	elif randx <= 10:
		randx = 20
	elif 10 < randx && randx < 1190:
		pos = Vector2(randx, 750)
	

	

func _ready():
	randomize()
	global_position = pos
	if randf() >= .5:
		selector.set_frame(0)
	else:
		selector.set_frame(1)
	#set_fixed_process(true)
	
	
func _fixed_process(delta):
	pos += vel * delta
	global_position = pos
	if global_position.y < 0:
		queue_free()
		global.booster_present = false
