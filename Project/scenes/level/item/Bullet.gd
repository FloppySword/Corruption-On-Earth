extends Area2D

var vel = Vector2()
export var speed = 2000


func start_at(dir, pos):
	#global_rotation = (-dir + PI)
	global_position = pos
#	set_rot(-dir + PI)
#	set_pos(pos)

	vel = Vector2(speed, 0).rotated(dir + PI/2)
	#vel.y *= -1 # + v

func _physics_process(delta):
	global_position += vel * delta
	
	if global_position.x > global.upper_bounds.x \
		or global_position.x < global.lower_bounds.x \
		or global_position.y > global.upper_bounds.y \
		or global_position.y < global.lower_bounds.y:
		queue_free()
		


func _on_Bullet_area_entered(area):

	if area.is_in_group("Character"):
		pass
	elif area.is_in_group("Metal"):
		pass
	elif area.is_in_group("Tire"):
		pass
	
	"""
	Chance bullet queue_frees or continues on (multi-target)
	"""
