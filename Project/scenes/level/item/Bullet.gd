extends Area2D

var vel = Vector2()
export var speed = 2000

var elapsed_time = 0


func start_at(dir, pos):
	#global_rotation = (-dir + PI)
	global_position = pos
#	set_rot(-dir + PI)
#	set_pos(pos)

	vel = Vector2(speed, 0).rotated(dir + PI/2)
	#vel.y *= -1 # + v

func _physics_process(delta):
	elapsed_time += delta
	global_position += vel * delta
	
	if global_position.x > global.upper_bounds.x \
		or global_position.x < global.lower_bounds.x \
		or global_position.y > global.upper_bounds.y \
		or global_position.y < global.lower_bounds.y:
		queue_free()


func _on_Bullet_area_entered(area):
	if area.is_in_group("Character"):
		var damage = 50 * (1 - elapsed_time)
		var character_scene
		if area.is_in_group("Player"):
			character_scene = area.owner
		elif area.is_in_group("Enemy"):
			character_scene = area
		character_scene._damage(character_scene, damage, "gunshot")
	elif area.is_in_group("Metal"):
		area.owner.hit_metal(global_position)
	elif area.is_in_group("Tire"):
		pass
		
	queue_free()
	
	"""
	TO-DO: Chance bullet queue_frees or continues on (multi-target)
	"""
