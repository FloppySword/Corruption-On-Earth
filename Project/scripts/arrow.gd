extends  KinematicBody2D

var vel = Vector2()
export var speed = 500
onready var whoosh_sound = get_node("whoosh_sound")

#func _ready():
#	set_fixed_process(true)
	
	
func start_at(dir, pos):
	global_rotation = -dir + PI
	global_position = pos
#	set_rot(-dir + PI)
#	set_pos(pos)
	vel = Vector2(speed, 0).rotated(dir + PI/2)
	vel.y *= -1 # + v

func _physics_process(delta):
	whoosh()
	global_position = position
	#set_pos(get_pos() + vel * delta)
	if global_position.x > 1200 or global_position.x < 0 or global_position.y > 700 or global_position.y < 0:
		queue_free()
		
		
func whoosh():
	var prox = global.player_pos - global_position
	if prox.length() < 70:
		
		#if get_pos().y < global.player_pos.y:
		whoosh_sound.play("arrow_whoosh1")
	



func _on_Area2D_body_enter( body ):
	if body.get_name() == "player":
		if body.dodging == false:
			global.player_health -= 5
			queue_free()
