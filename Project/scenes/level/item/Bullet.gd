extends Node2D

onready var sprite = $Sprite
onready var ray = $RayCast2D

export(int) var speed = 2500

var elapsed_time:float = 0
var vel:Vector2 = Vector2()
var cast_pos:Vector2 = Vector2.ZERO
var collision_pos:Vector2 = Vector2(-999, -999)
var spent:bool = false
var can_hit:bool = true
var gunshots:Array = [
						"res://data/sound/effects/player/gunshot_1.wav",
						"res://data/sound/effects/player/gunshot_2.wav",
						"res://data/sound/effects/player/gunshot_3.wav"
						]
var shooter


func start_at(dir, pos, _shooter):
	shooter = _shooter

	global_position = pos
	
	# Rotate the node 90 degrees (because of the way the sprite was drawn)
	var rot = dir + PI/2
	# Rotate the raycast and sprite to this rot value. 
	ray.global_rotation = rot
	sprite.global_rotation = rot
	# Set the velocity to be in the direction of the rotation. 
	vel = Vector2(speed, 0).rotated(rot)
	
	ray.enabled = true
	ray.force_raycast_update()
	
	# Randomly select one of three gunshot sounds and play it.
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var idx = rng.randi_range(0,2)
	var sfx = load(gunshots[idx]) 
	$AudioStreamPlayer2D.stream = sfx
	$AudioStreamPlayer2D.play()

func _physics_process(delta):
	elapsed_time += delta
	if elapsed_time > 0.1 && !spent:
		# Disable the raycast, preventing it from detecting any more
		# collisions. The spent boolean helps make sure this only
		# happens once.
		spent = true
		ray.enabled = false
		ray.force_raycast_update()
		return
	
	# Move the bullet sprite but not the raycast.
	sprite.global_position += vel * delta
	sprite.scale.x = 60#min(sprite.scale.x + 10, 60)
	
	
	if ray.is_colliding() && !spent:
		# As long as unspent, register the hit as valid. 
		hit_area(ray.get_collider(), ray.get_collision_point())
	
	# The sprite is basically just an effect so subject it to the same
	# global bounds parameters. If it exceeds, hide it.
	if sprite.global_position.x > Global.upper_bounds.x \
		or sprite.global_position.x < Global.lower_bounds.x \
		or sprite.global_position.y > Global.upper_bounds.y \
		or sprite.global_position.y < Global.lower_bounds.y \
		or sprite.global_position.distance_to(collision_pos) < 40 \
		or elapsed_time > 1:
		hide()
		# But only queue_free the audio if it's finished, otherwise let
		# it finish.
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
	if area.is_in_group("Character"):
		# Primary damage starts off at 100 but loses value the further away the shot
		# was from the target.
		var primary_damage = Global.bullet_primary_damage - (0.2 * collision_dist)
		# Additional damage is low, and with added randomness
		var adtl_damage = Global.bullet_adtl_damage + rng.randi_range(-5, 5)
		var damage = primary_damage + adtl_damage #max(adtl_damage, primary_damage)
		# Clamp the calculated damage between the global min and max
		damage = clamp(damage, Global.gun_dmg_min,Global.gun_dmg_max)
		#print("primary: " + str(primary_damage))
		#print("additional: " + str(adtl_damage))
		#print("damage: " + str(damage))
		var character_scene
		var damage_type = "gunshot"
		if area.is_in_group("Player"):
			character_scene = area.owner
		elif area.is_in_group("Enemy"):
			# Only enemies can get headshot.
			if area.is_in_group("Head"):
				character_scene = area.owner
				damage_type = "headshot"
				# 1-shot kill, ignore above damage calculation
				damage = 100
			else:
				# Use the above damage calculation
				character_scene = area
		character_scene._damage(area, damage, damage_type, collision_pos)
	else:
		# If a non-character was shot.
		if shooter == "Player":
			if area.is_in_group("Metal"):
				area.owner._hit_metal(collision_pos)
			elif area.is_in_group("Tire"):
				area.owner._hit_tire(collision_pos)
		elif shooter == "Enemy":
			if area.is_in_group("Horse"):
				var damage = 15
				area.owner._damage(area, damage, "gunshot", collision_pos)

	
	"""
	TO-DO: Chance bullet queue_frees or continues on (multi-target)
	"""
