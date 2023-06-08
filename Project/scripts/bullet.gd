extends  KinematicBody2D

var vel = Vector2()
export var speed = 1000

func _ready():
	set_fixed_process(true)

func start_at(dir, pos):
	set_rot(-dir + PI)
	set_pos(pos)
	vel = Vector2(2000, 0).rotated(dir + PI/2)
	vel.y *= -1 # + v

func _fixed_process(delta):
	set_pos(get_pos() + vel * delta)
	if get_pos().x > 1200 or get_pos().x < 0 or get_pos().y > 700 or get_pos().y < 0:
		queue_free()
		




func _on_Area2D_body_enter( body ):
	if body.get_groups().has("enemies"):
		print(body.get_name(), get_pos())
