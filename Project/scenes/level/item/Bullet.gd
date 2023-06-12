extends Area2D

var vel = Vector2()
export var speed = 2000


var elapsed_time = 0

var can_hit = true


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
	if can_hit:
		
		if area.is_in_group("Character"):
			can_hit = false
			var damage = 50 * (1 - elapsed_time)
			var character_scene
			var damage_type = "gunshot"
			if area.is_in_group("Player"):
				character_scene = area.owner
			elif area.is_in_group("Enemy"):
				if area.is_in_group("Head"):
					character_scene = area.owner
					damage_type = "headshot"
				else:
					character_scene = area
			character_scene._damage(character_scene, damage, damage_type, global_position)
		elif area.is_in_group("Metal"):
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			if rng.randf() >= 0.5:
				can_hit = false
				area.owner._hit_metal(global_position)
		elif area.is_in_group("Tire"):
			can_hit = false
			area.owner._hit_tire(global_position)
		

	else:
		queue_free()
	
	"""
	TO-DO: Chance bullet queue_frees or continues on (multi-target)
	"""



