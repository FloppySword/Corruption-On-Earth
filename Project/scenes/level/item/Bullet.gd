extends Node2D

var vel = Vector2()
export var speed = 2500

var spent = false

var elapsed_time = 0
var shooter
var can_hit = true

var cast_pos = Vector2.ZERO
var collision_pos = Vector2(-999, -999)


var gunshots = [
						"res://data/sound/effects/player/gunshot_1.wav",
						"res://data/sound/effects/player/gunshot_2.wav",
						"res://data/sound/effects/player/gunshot_3.wav"
						]

onready var sprite = $Sprite
onready var ray = $RayCast2D


func start_at(dir, pos, _shooter):
	shooter = _shooter

	global_position = pos

	var rot = dir + PI/2
	ray.global_rotation = rot
	sprite.global_rotation = rot
	vel = Vector2(speed, 0).rotated(rot)
	
	ray.enabled = true
	ray.force_raycast_update()
	
	
	#manage sound effect
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var idx = rng.randi_range(0,2)
	var sfx = load(gunshots[idx]) 
	#sfx.set_loop(false)
	$AudioStreamPlayer2D.stream = sfx
	$AudioStreamPlayer2D.play()
	#SoundManager.play_sound($AudioStreamPlayer2D.stream)


func _physics_process(delta):
	elapsed_time += delta
	if elapsed_time > 0.1 && !spent:
		spent = true
		ray.enabled = false
		ray.force_raycast_update()
		return

	sprite.global_position += vel * delta
	sprite.scale.x = 60#min(sprite.scale.x + 10, 60)
	
	
	if ray.is_colliding() && !spent:
		hit_area(ray.get_collider(), ray.get_collision_point())
	
		
	if sprite.global_position.x > Global.upper_bounds.x \
		or sprite.global_position.x < Global.lower_bounds.x \
		or sprite.global_position.y > Global.upper_bounds.y \
		or sprite.global_position.y < Global.lower_bounds.y \
		or sprite.global_position.distance_to(collision_pos) < 40 \
		or elapsed_time > 1:
		hide()
		if !$AudioStreamPlayer2D.playing:
			queue_free()

func hit_area(area, _collision_pos):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	#Prevent friendly fire
	if (area.is_in_group("Player") && shooter == "Player") \
		or (area.is_in_group("Enemy") && shooter == "Enemy"):
		ray.add_exception(area)
		ray.force_raycast_update()
		return
	
	spent = true
	ray.enabled = false
	ray.force_raycast_update()
	
	collision_pos = _collision_pos
	var collision_dist = global_position.distance_to(collision_pos)
	
	#print(area.name)
	
	if area.is_in_group("Character"):
		var primary_damage = Global.bullet_primary_damage - (0.8 * collision_dist)
		var adtl_damage = Global.bullet_adtl_damage + rng.randi_range(-5, 5)
		var damage = max(adtl_damage, primary_damage)
		damage = clamp(damage, Global.gun_dmg_min,Global.gun_dmg_max)
		#print(collision_dist)
		var character_scene
		var damage_type = "gunshot"
		if area.is_in_group("Player"):
			character_scene = area.owner
		elif area.is_in_group("Enemy"):
			if area.is_in_group("Head"):
				character_scene = area.owner
				damage_type = "headshot"
				damage = 100
			else:
				character_scene = area
		character_scene._damage(area, damage, damage_type, collision_pos)
	else:
		if shooter == "Player":
			if area.is_in_group("Metal"):
				area.owner._hit_metal(collision_pos)
			elif area.is_in_group("Tire"):
				area.owner._hit_tire(collision_pos)
		elif shooter == "Enemy":
			if area.is_in_group("Horse"):
				var damage = 15
				area.owner._damage(area, damage, "gunshot", collision_pos)
	

		

		
		
		


	
	

		
#func hit_area(area):
#	pass

#
#func _on_Bullet_area_entered(area):
#	if area.is_in_group("Player") && shooter == "Player":
#		return
#	if area.is_in_group("Enemy") && shooter == "Enemy":
#		return
#
#	if can_hit:
#		var rng = RandomNumberGenerator.new()
#		rng.randomize()
#
#		if area.is_in_group("Character"):
#			can_hit = false
#			var damage = 50 * (1 - elapsed_time)
#			var character_scene
#			var damage_type = "gunshot"
#			if area.is_in_group("Player"):
#				character_scene = area.owner
#			elif area.is_in_group("Enemy"):
#				if area.is_in_group("Head"):
#					character_scene = area.owner
#					damage_type = "headshot"
#				else:
#					character_scene = area
#			character_scene._damage(character_scene, damage, damage_type, global_position)
#		elif area.is_in_group("Metal"):
#
#			if rng.randf() >= 0.5:
#				can_hit = false
#				area.owner._hit_metal(global_position)
#		elif area.is_in_group("Tire"):
#			can_hit = false
#			area.owner._hit_tire(global_position)
#		elif area.is_in_group("Horse"):
#			pass
#
#		rng.randomize()
#		if rng.randf() >= 0.75:
#			queue_free()
#
#
#	else:
#		queue_free()
	
	"""
	TO-DO: Chance bullet queue_frees or continues on (multi-target)
	"""





func _on_AudioStreamPlayer2D_finished():
	pass # Replace with function body.
