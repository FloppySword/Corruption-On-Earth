extends KinematicBody2D

# Shortcut variables for scene nodes.
onready var front_tire = $SpriteRear/SpriteFront/SpriteTire
onready var seat1 = $SpriteRear/Seat1
onready var seat2 = $SpriteRear/Seat2
onready var motorcycle_rear = $SpriteRear
onready var motorcycle_front = $SpriteRear/SpriteFront

# Instance scene variables
var Enemy = preload("res://scenes/level/character/enemy/Enemy.tscn")
var MetalImpact = preload("res://scenes/level/character/effects/MetalImpact.tscn")

# Movement variables
var pos:Vector2 = Vector2()
var speed:int = 90
var rot:float = 0
var vel:Vector2 = Vector2(0, 0)
var collision_count = 0
var entered_visible_area:bool = false

# Boid variables
var _flock:Array = []
var target_force:float = 0
var cohesion_force:float = 0
var alignment_force:float = 0
var separation_force:float = 0
var view_distance:float = 0
var avoid_distance:float = 0
var target:Vector2 = Vector2()
#var target_dist

# Null variables that are set as the driver and passenger are instanced (which
# happens in the _initiate function). 
var driver
var passenger

#State variables
enum vehicleStates {FlatTire, DriverDead, Normal, Explode}
var vehicle_state = vehicleStates.Normal

signal skid
signal rider_shoot
signal explosion

func _ready():
	randomize()
	
	# Set boid variables to Global boid variables
	target_force = Global.target_force
	cohesion_force = Global.cohesion_force
	alignment_force = Global.alignment_force
	separation_force = Global.separation_force
	view_distance = Global.view_distance
	$BoidArea2D.get_node("CollisionShape2D").shape.radius = view_distance
	avoid_distance = Global.avoid_distance
	
	# Delay playing of motorcycle sound so that they aren't all playing at the same time.
	# Note: this is already sort of dealt with by the fact that spawning is staggered 
	# for enemies in each wave.
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	yield(get_tree().create_timer(rng.randf_range(0.1, 1.7)), "timeout")
	if weakref(self).get_ref():
		$AudioStreamPlayer2D.play()
	
func _initiate(spawnpos, type):
	global_position = spawnpos
	
	# Variable to append to type string to set whether the enemy is armed
	# Types are as follows:
	#	u = solo unarmed,
	#	a = armed,
	#	du = duo unarmed
	#	da = duo armed
	# (These are from the Global waves array)
	var armed
	if "u" in type:
		armed = ""
	elif "a" in type:
		armed = "Armed"
	
	# No matter what, a driver is spawned. We'll call the local instance "e1"
	var e1 = Enemy.instance()
	seat1.add_child(e1)
	e1._initiate(seat1.global_position, "Driver"+armed, self)
	driver = e1
	
	if "d" in type:
		# If there's a passenger, we'll call the local instance "e2". 
		var e2 = Enemy.instance()
		seat2.add_child(e2)
		e2._initiate(seat2.global_position, "Passenger", self)
		passenger = e2
	
	# Set the color of the motorcycle based on the type. 
	var color 
	if type == "u":
		color = Color.mediumaquamarine
	elif type == "a":
		color = Color.orangered
	elif type == "du":
		color = Color.lightslategray
	elif type == "da":
		color = Color.fuchsia
	
	# Since two separate sprites, set both to color the whole motorcycle. 
	motorcycle_rear.self_modulate = color 
	motorcycle_front.self_modulate = color 

func _physics_process(delta):
	# A skid effect gets spawned every single delta to create an unbroken tiremark trail
	emit_signal("skid", global_position + Vector2(0, 10), "tire")
	# Consider passing rotation of front and making treadmark rotate
	
	var acceleration = Vector2.ZERO
	var flock_vectors = determine_flock_status()
	# Breakout returned flock_vectors array into individual vector variables
	var cohesion_vector = flock_vectors[0] * cohesion_force
	var alignment_vector = flock_vectors[1] * alignment_force
	var separation_vector = flock_vectors[2] * separation_force
	var target_vector = (target - global_position).normalized() * speed * target_force
	
	acceleration = cohesion_vector + alignment_vector + separation_vector + target_vector
	
	# Do not let vel exceed speed
	vel = (vel + acceleration).clamped(speed)
	
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()


	match vehicle_state:
		#Driver is alive and driving normally
		vehicleStates.Normal:
			# Set speed initially  to global enemy speed variable.
			speed = Global.enemy_speed_normal

			var target_type = ""
			if driver.ammo > 0 || (passenger && passenger.ammo > 0):
				# Vehicle will keep its distance from player horse so rider(s) can shoot
				target_type = "shoot"
			else:
				# Vehicle will get close to player horse so driver can kick
				target_type = "kick"
				
			if global_position.x <= Global.player.global_position.x:
				# If vehicle is to the left of player horse
				if target_type == "shoot":
					target = Global.player.shoot_pos_left.global_position
				elif target_type == "kick":
					target = Global.player.kick_pos_left.global_position
			else:
				# If vehicle is to the right of player horse (or x-aligned but that would
				# only be for a brief moment)
				if target_type == "shoot":
					target = Global.player.shoot_pos_right.global_position
				elif target_type == "kick":
					target = Global.player.kick_pos_right.global_position
			
			# Edit speed depending on distance to target
			var target_dist = global_position.distance_to(target)
			speed = speed + (0.2 * target_dist)
			
			# Debugger icon, keep hidden
			$Icon.global_position = target
			
		# Vehicle has a flat tire and has backward velocity
		vehicleStates.FlatTire:
			speed = 300
		# Driver is dead and vehicle is swerving off-screen
		vehicleStates.DriverDead:
			speed = rng.randi_range(200, 350)
		# Vehicle has exploded (WIP)
		vehicleStates.Explode:
			speed = 0
	
	# Play turning animations if velocity's x is beyond straight-forward threshold (-70, 70)
	var turn_dir
	if vel.x > 70:
		turn_dir = "TurnLeft"
		$AnimationPlayer.play("MotorcycleTurnLeft")
	elif vel.x < -70:
		turn_dir = "TurnRight"
		$AnimationPlayer.play("MotorcycleTurnRight")
	else:
		turn_dir = "Straight"
		$AnimationPlayer.play("Motorcycle"+turn_dir)
	
	# This initiated var is just a measure to ensure that the proper setup animation plays
	# for the driver (Enemy.tscn) when it's initiated. 
	if driver.initiated:
		driver.set_anim("MotorcycleDriver"+turn_dir)

	
	var collision = move_and_collide(vel * delta)
	if collision:
		if vehicle_state != vehicleStates.Normal:
			# If driver dead or flat tire
			if collision_count >= 3:
				# If the vehicle has bounced against another at least 3 times, 
				# set the target to be its own x and a negative y (so it travels
				# backward.
				target.x = global_position.x
				target.y = -170
			else:
				#Explosion is WIP. Leave commented out for now. 
				#if driver.dead:
					#trigger_explosion(collision.collider)
				
				# Bounce this vehicle off the collider
				vel = vel.bounce(collision.normal) 
				collision_count += 1
		else:
			# If vehicle is driving normally, bounce off collider at 0.5x intensity
			vel = 0.5 * vel.bounce(collision.normal) 
		

	# If vehicle state is normal, don't let the vehicle queue_free even if it's outside
	# the level's bounds. But if it's got a dead driver or flat tire, queue_free once it
	# exceeds bounds. 
	if !vehicle_state == vehicleStates.Normal:#!vehicle_state == vehicleStates.Explode:
		if global_position.x > Global.upper_bounds.x \
			or global_position.x < Global.lower_bounds.x \
			or global_position.y > Global.upper_bounds.y \
			or global_position.y < Global.lower_bounds.y:
			queue_free()
	# But if vehicle state is normal, don't let driver go off-screen
	# once they've been on screen. 
	else:
		# Check whether enemy vehicle has ever been within visible area
		if !entered_visible_area:
			if (global_position.x > Global.player_lower_bounds.x && global_position.x < Global.player_upper_bounds.x) && \
				(global_position.y > Global.player_lower_bounds.y && global_position.y < Global.player_upper_bounds.y):
					entered_visible_area = true
		else:
			# Prevent the vehicle from travelling outside the bounds of the gameplay window. 
			# Note: perhaps bounds should be renamed since not only being used for player.
			global_position.x = clamp(global_position.x, Global.player_lower_bounds.x, Global.player_upper_bounds.x)
			global_position.y = clamp(global_position.y, Global.player_lower_bounds.y, Global.player_upper_bounds.y)
		
			

# Add neighbor vehicle to flock if within view area
func _on_BoidArea2D_body_entered(body):
	if self != body && body.is_in_group("EnemyVehicle"):
		_flock.append(body)

# Remove neighbor vehicle from flock if it surpasses view area. 
func _on_BoidArea2D_body_exited(body):
	if self != body && _flock.has(body):
		_flock.remove(_flock.find(body))

# Called in _physics_process to set flock_vectors variable
func determine_flock_status():
	var center_vector = Vector2.ZERO
	var flock_center = Vector2.ZERO
	var alignment_vector = Vector2.ZERO
	var avoid_vector = Vector2.ZERO
	
	# Ignore flocking behavior if vehicle state isn't normal.
	if vehicle_state != vehicleStates.Normal:
		return [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
	
	# Iterate over neighbors (other vehicles within view distance)
	for f in _flock:
		var neighbor_pos = f.global_position
		alignment_vector += f.vel
		flock_center += neighbor_pos

		var d = global_position.distance_to(neighbor_pos)
		if d > 0 and d < avoid_distance:
			avoid_vector -= (neighbor_pos - global_position).normalized() * (avoid_distance / d * speed)
	
	var flock_size = _flock.size()
	if flock_size:
		# Set the alignment vector to be the average velocity of the flock
		alignment_vector /= flock_size
		# Set the flock center to be the average position of the flock
		flock_center /= flock_size
		var center_dir = global_position.direction_to(flock_center)
		var center_speed = speed * (global_position.distance_to(flock_center) / view_distance)
		# Set the cohesion vector to be the product of the vehicle's 
		# direction toward the flock center & the vehicle's speed
		center_vector = center_dir * center_speed
	
	# Return these three calculated vectors back to the _physics process flock_vectors var.
	return [center_vector, alignment_vector, avoid_vector]

func _rider_shoot(bullet_rot, bullet_pos, shooter):
	# Possibly confusing because here "rider" can refer to either driver or
	# passenger. ALL Enemy.tscn instances are connected to this function via
	# their "shoot" signal. 
	#So "rider" = "any person on the motorcycle"
	emit_signal("rider_shoot", bullet_rot, bullet_pos, shooter)

func _hit_metal(hit_pos):
	# Locally instance a metal impact effect and play audio. 
	var m = MetalImpact.instance()
	add_child(m)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	m.global_rotation = rng.randi_range(-180, 180)
	m.global_position = hit_pos
	m._set_audio()
	m.play('default')

func _hit_tire(hit_pos):
	# If vehicle isn't driving normally, do nothing. 
	if vehicle_state == vehicleStates.Normal:
		# Play tire explosion animation
		front_tire.play("flat")
		# Spawn tire explosion effect
		#(Reusing MetalImpact for this)
		var t = MetalImpact.instance()
		add_child(t)
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		t.global_rotation = rng.randi_range(-180, 180)
		
		# Boolean variable in MetalImpact.tscn to designate whether instance is
		# tire (true) or truly a metal impact effect (false)
		t.tire = true
		
		t.scale = Vector2(2, 2)
		t.global_position = hit_pos
		t.modulate = Color.black
		
		# Play tire popping sound
		var stream = $SpriteRear/SpriteFront/SpriteTire/TireArea2D/AudioStreamPlayer2D.stream
		SoundManager.play_sound(stream)
		t.play("default")
		
		#Change state from normal to flat tire
		vehicle_state = vehicleStates.FlatTire
		
		# Set new target for travelling off-screen and queueing free
		reshuffle_dead_target()

	
func _driver_dead():
	# If vehicle isn't driving normally, do nothing. 
	# For instance, if tire already flat, nothing needs to change.
	# The vehicle is already travelling off-screen and the driver
	# being dead has no impact. 
	# Unless, of course, we want to change that for added detail. 
	if vehicle_state == vehicleStates.Normal:
		vehicle_state = vehicleStates.DriverDead
	
		# Set new target for travelling off-screen and queueing free
		reshuffle_dead_target()

func _passenger_dead():
	# Clears the passenger variable, which will allow the vehicle's target
	# to swap to the player's kick target (unless the driver has ammo remaining)
	passenger = null


func trigger_explosion(collider):
	#WIP, return for now
	return
	emit_signal("explosion", self, collider)
	
	vehicle_state = vehicleStates.Explode
	
func reshuffle_dead_target():
	# Set an appropriate destination target when vehicle is leaving map 
	# (either because driver killed or flat tire). 
	match vehicle_state:
		vehicleStates.FlatTire:
			randomize()
			var possible_targets = [0, 1, 2]
			possible_targets.shuffle()
			target = Global.die_targets.get_child(possible_targets[0]).global_position
		vehicleStates.DriverDead:
			randomize()
			var possible_targets = [3, 4, 5, 6]
			possible_targets.shuffle()
			target = Global.die_targets.get_child(possible_targets[0]).global_position
			vehicle_state = vehicleStates.DriverDead




