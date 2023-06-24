extends KinematicBody2D

signal skid
signal rider_shoot
signal explosion

var pos = Vector2()
var speed = 90
var rot = 0
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)

#var new_vel_x
#var new_vel_y
#var colliding = false
var collision_count = 0
	
	
var _flock = []
var target_force = 0
var cohesion_force = 0
var align_force = 0
var separation_force = 0
var view_distance = 0
var avoid_distance = 0
#
#const AVOID_RADIUS = 150
#const DETECT_RADIUS = 1200
#const FRICTION = -500

var target = Vector2()
var target_dist

var driver
var passenger

enum vehicleStates {FlatTire, DriverDead, Normal, Explode}
var vehicle_state = vehicleStates.Normal





#var in_shoot_range = false

var Enemy = preload("res://scenes/level/character/enemy/Enemy.tscn")

var MetalImpact = preload("res://scenes/level/character/MetalImpact.tscn")

onready var front_tire = $SpriteRear/SpriteFront/SpriteTire
onready var seat1 = $SpriteRear/Seat1
onready var seat2 = $SpriteRear/Seat2
onready var motorcycle_rear = $SpriteRear
onready var motorcycle_front = $SpriteRear/SpriteFront

func _ready():
	randomize()
	target_force = Global.target_force
	cohesion_force = Global.cohesion_force
	align_force = Global.align_force
	separation_force = Global.separation_force
	view_distance = Global.view_distance
	$BoidArea2D.get_node("CollisionShape2D").shape.radius = view_distance
	avoid_distance = Global.avoid_distance
	
func init(spawnpos, type):
	global_position = spawnpos
	
	var armed
	if "u" in type:
		armed = ""
	elif "a" in type:
		armed = "Armed"
		
	var e1 = Enemy.instance()
	seat1.add_child(e1)
	e1.init(seat1.global_position, "Driver"+armed, self)
	driver = e1
	
	if "d" in type:
		#$Seat1.add_child()
	#if type == "MotorcycleDuo":
		var e2 = Enemy.instance()
		seat2.add_child(e2)
		e2.init(seat2.global_position, "Passenger", self)
		passenger = e2
	
	var color 
	if type == "u":
		color = Color.mediumaquamarine
	elif type == "a":
		color = Color.orangered
	elif type == "du":
		color = Color.lightslategray
	elif type == "da":
		color = Color.fuchsia
	
	motorcycle_rear.self_modulate = color 
	motorcycle_front.self_modulate = color 
	
		
func _rider_shoot(bullet_rot, bullet_pos, shooter):
	emit_signal("rider_shoot", bullet_rot, bullet_pos, shooter)
		
		
func _hit_metal(hit_pos):
	var m = MetalImpact.instance()
	add_child(m)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	m.global_rotation = rng.randi_range(-180, 180)
	m.global_position = hit_pos
	m.play('default')
	
	
#State changing functions
func _hit_tire(hit_pos):
	if vehicle_state == vehicleStates.Normal:
		front_tire.play("flat")
		
		#reusing MetalImpact for this
		var t = MetalImpact.instance()
		add_child(t)
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		t.global_rotation = rng.randi_range(-180, 180)
		t.tire = true
		#t.speed_scale = 2
		t.scale = Vector2(2, 2)
		t.global_position = hit_pos
		t.modulate = Color.black
		t.play("default")
		
		vehicle_state = vehicleStates.FlatTire
		
		reshuffle_dead_target()
		
		
		

		#set new target
		
		
	
func _driver_dead():
	if vehicle_state == vehicleStates.Normal:
		#$BoidArea2D.monitoring = false
		vehicle_state = vehicleStates.DriverDead
		reshuffle_dead_target()


		
func trigger_explosion(collider):
	return
	emit_signal("explosion", self, collider)
	
	vehicle_state = vehicleStates.Explode
	
	
func reshuffle_dead_target():
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


		
func _physics_process(delta):
	#consider passing rotation of front and making treadmark rotate
	emit_signal("skid", global_position + Vector2(0, 10), "tire")
	
	
#	if colliding:
#		reshuffle_dead_target()

	
	var acceleration = Vector2.ZERO
	var vectors = get_flock_status()
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * align_force
	var separation_vector = vectors[2] * separation_force
	var target_vector = (target - global_position).normalized() * speed * target_force
	
#	if target.distance_to(global_position) < 100:
#		target_vector = Vector2.ZERO

	acceleration = cohesion_vector + align_vector + separation_vector + target_vector
	
	vel = (vel + acceleration).clamped(speed)
	
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if vehicle_state == vehicleStates.Normal:
		var target_type = ""
		if driver.ammo > 0 || (passenger && passenger.ammo > 0):
			target_type = "shoot"
		else:
			target_type = "kick"
			
		#target = Global.player.global_position

		if global_position.x >= Global.player.global_position.x:
			if target_type == "shoot":
				target = Global.player.shoot_pos_left.global_position
			elif target_type == "kick":
				target = Global.player.kick_pos_left.global_position
			
		else:
			if target_type == "shoot":
				target = Global.player.shoot_pos_right.global_position
			elif target_type == "kick":
				target = Global.player.kick_pos_right.global_position
			
		$Icon.global_position = target
	
		
		
	match vehicle_state:
		vehicleStates.Normal:
			speed = 150
		
		vehicleStates.FlatTire:
			speed = 300
#		
		vehicleStates.DriverDead:
			speed = rng.randi_range(200, 350)
#			
		vehicleStates.Explode:
			speed = 0
#			
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
	if driver.initiated:
		driver.set_anim("MotorcycleDriver"+turn_dir)


	var collision = move_and_collide(vel * delta)
	if collision:
		if vehicle_state != vehicleStates.Normal:
			if collision_count >= 3:
				target.x = global_position.x
				target.y = -170
			else:
	#			if driver.dead:
	#				trigger_explosion(collision.collider)
				
				vel = vel.bounce(collision.normal) 
				collision_count += 1
	

	if !vehicle_state == vehicleStates.Normal:#!vehicle_state == vehicleStates.Explode:
		if global_position.x > Global.upper_bounds.x \
			or global_position.x < Global.lower_bounds.x \
			or global_position.y > Global.upper_bounds.y \
			or global_position.y < Global.lower_bounds.y:
			queue_free()
		
		


func get_flock_status():
	var center_vector: = Vector2()
	var flock_center: = Vector2()
	var align_vector: = Vector2()
	var avoid_vector: = Vector2()
	
	if vehicle_state != vehicleStates.Normal:
		return [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
		
	for f in _flock:
		
		var neighbor_pos: Vector2 = f.global_position

		align_vector += f.vel
		flock_center += neighbor_pos

		var d = global_position.distance_to(neighbor_pos)
		if d > 0 and d < avoid_distance:
			avoid_vector -= (neighbor_pos - global_position).normalized() * (avoid_distance / d * speed)
	
	var flock_size = _flock.size()
	if flock_size:
		align_vector /= flock_size
		flock_center /= flock_size

		var center_dir = global_position.direction_to(flock_center)
		var center_speed = speed * (global_position.distance_to(flock_center) / view_distance)
		center_vector = center_dir * center_speed

	return [center_vector, align_vector, avoid_vector]


func _on_BoidArea2D_body_entered(body):
	if self != body && body.is_in_group("EnemyVehicle"):
		_flock.append(body)


func _on_BoidArea2D_body_exited(body):
	if self != body && _flock.has(body):
		_flock.remove(_flock.find(body))

