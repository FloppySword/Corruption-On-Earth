extends Area2D

onready var anim_player = $AnimationPlayer
onready var kick_timer = $Detectors/KickDetector/KickTimer
onready var kick_detector = $Detectors/KickDetector
onready var muzzle = $ArmLeft/Gun/Muzzle

var BloodImpact = preload("res://scenes/level/character/effects/BloodEffect.tscn")

var type:String = ""
var vehicle:KinematicBody2D
var initiated:bool = false
var already_kicked:bool = false
var dead:bool = false
var anim_locked:bool = true
var health:int = 100
var ammo:int = 19
var vel:Vector2 = Vector2.ZERO
var target_rot:float = 0
# This dictionary controls settings for passengers and drivers w/ guns.
# Their RotLimit is essentially the absolute value of their range of mmotion in 
# radians. 
var armed_vars:Dictionary = {"Passenger":
								{"ViewDist":400,
								"RotLimit":2.55},
							"DriverArmed":
								{"ViewDist":350,
								"RotLimit":1.85}}

# Set to negative to disable "falling" position manipulation in 
# physics process. 
var dead_pos:Vector2 = Vector2(-100, -100)

signal ready_to_fire
signal shoot
signal fall


func _initiate(pos, _type, _vehicle):
	# Set vehicle to the parent vehicle which spawned this enemy
	vehicle = _vehicle
	type = _type
	global_position = pos
	if type == "Passenger":
		ammo = 19
		#The passenger cannot kick. Might add jumping though. 
		$Detectors/KickDetector.monitoring = false
	elif type == "DriverArmed":
		ammo = 9#19
	elif type == "Driver":
		ammo = 0

	# These are setup animations that only need to play briefly
	# at initiation. 
	anim_player.play("Motorcycle"+type)
	
	# The anim_unlock function allows for the animations to change.
	anim_unlock()
	
	# Connect to vehicle and Global scripts to call remote 
	# functions handling rider shooting 
	connect("shoot", vehicle, "_rider_shoot")
	connect("ready_to_fire", Global, "_enemy_remote_shoot")
	connect("fall", Global, "_enemy_remote_fall")
	
func _set_initiated():
	initiated = true
	
func _physics_process(delta):
	if ammo > 0 && type in ["DriverArmed", "Passenger"] && $ArmLeft/ReactionTimer.time_left == 0:
		# If all conditions are true, the reaction timer starts. See timeout function for whata
		# happens next.
		$ArmLeft/ReactionTimer.start()
#			
	if dead:
		if dead_pos.x != -100:
			#If dead_pos.x is different than the original value, i.e. the enemy has fallen
			# off the bike, we want to keep the x position constant so that the body isn't flying
			# all over the place. 
			global_position.x = dead_pos.x
		# Only does anything if enemy is falling because otherwise vel will be Vector2.ZERO.
		global_position.y += vel.y * delta
	
func _damage(hitbox, damage, type, pos):
	var blood_impact = BloodImpact.instance()
	add_child(blood_impact)
	blood_impact._initiate(pos, type)

	health -= damage
	if health <= 0:
		# If already dead do nothing
		if !dead:
			# Otherwise show blod and call die()
			if type == "headshot":
				$Head/HeadBlood.show()
				if health < 0: #if damaged before
					$Torso/TorsoBlood.show()
			elif type == "gunshot":
				$Torso/TorsoBlood.show()
			die()
# Possibly add bleeding when health is low?
#	elif health < 20:
#		vehicle._bleed()

func die():
	dead = true
	anim_lock()
	anim_player.play("Die"+type+"Normal")
	
	# Send info back to vehicle scene that it's dead
	if "Driver" in type:
		vehicle._driver_dead()
	else:
		vehicle._passenger_dead()
	
	
	
func fall():
	# Called from "DiePassengerNormal" animatin in AnimationPlayer
	
	# Set dead_pos which is used in _physics_process
	dead_pos = global_position
	# Set vel to global ground velocity for all things that are "moving" upward
	# (relative to automatic "downward" camera movement going on at all times). 
	vel = Global.ground_vel

func set_anim(animation):
	# Do nothing if anim_locked is true
	if !anim_locked:
		anim_player.play(animation)
	
func anim_lock():
	anim_locked = true
	
func anim_unlock():
	# Reset the already_kicked boolean which is only relevant during the kicking action to
	# ensure only one kick happens at a time
	already_kicked = false
	anim_locked = false

	
func _shoot():
	if dead:
		return
	ammo -= 1
	
	# Connects to EnemyVehicle.tscn which in turn connects to Level1.tscn
	# to spawn a bullet following the provided parameters
	emit_signal("shoot", target_rot, muzzle.global_position, "Enemy")
	# Prevent interruption  or double-shooting
	anim_lock()
	
	anim_player.play("Shoot")
	
	
func _check_ammo():
	if ammo <= 0:
		# Hide gun
		anim_player.play("OutOfAmmo")
		if type == "DriverArmed":
			# Change driver type to ensure correct behavior going forward (kicking  not shooting)
			type = "Driver"
		
		# Reset animation (so enemy is no longer aiming empty gun)
		anim_player.play("Motorcycle"+type)

func set_target_force(end:bool):
	# Begin + End function to make the kicking vehicle "stick"
	# to the player horse while enemy is kicking.
	# Called at beginning and end of "MotorcycleDriverKick" animations
	# in AnimationPlayer
	
	if !end:
		# At beginning, make vehicle's target force strong and ignore separation force
		vehicle.target_force = Global.target_force * 5
		vehicle.separation_force = 0
	else:
		# At end, reset forces back to default
		vehicle.target_force = Global.target_force
		vehicle.separation_force = Global.separation_force
		

func _on_KickDetector_area_entered(area):
	if area.is_in_group("Enemy") || dead || kick_timer.time_left > 0:
		# Do nothing if dead, friendly fire, or kick cooldown not over
		return
		
	if type == "Driver":
		#If passenger, do nothing
		
		anim_lock()
		if area.global_position.x > global_position.x:
			anim_player.play("MotorcycleDriverKickLeft")
		elif area.global_position.x < global_position.x:
			anim_player.play("MotorcycleDriverKickRight")
		else:
			# Shouldn't happen
			anim_unlock()
			

func apply_kick_damage():
	# Note: if there were more than one target for the enemy, this would break in its current state
	# because the KickDetector's two collision shapes are currently active. So theoretically damage could be applied
	# to the wrong of two flanking horses on either side of the motorcycle, e.g. if the enemy kicked left but the
	# right horse was damaged instead. 
	# For now though, fine as-is. 
	
	var areas = kick_detector.get_overlapping_areas()
	if areas.size() > 0:
		# Get first (and should be only) area that's overlapping, which should be the player horse hitbox.
		var area = areas[0]
		# The area's owner is the root PlayerHorse scene.
		var character_scene = area.owner
		var damage = 5
		var damage_type = "kick"
		var kick_pos
		var kick_padding = Vector2(2, 0)
		# Add some padding to the kick position so that the kick effect doesn't look strange. 
		if anim_player.current_animation == "MotorcycleDriverKickRight":
			kick_pos = $Detectors/KickDetector/LeftCollisionShape2D.global_position
			kick_pos -= kick_padding
		else:
			kick_pos = $Detectors/KickDetector/RightCollisionShape2D.global_position
			kick_pos += kick_padding
		
		# Prevent multiple kick events from registering incorrectly
		if !already_kicked:
			already_kicked = true
			# Remote call player horse's _damage function.
			character_scene._damage(area, damage, damage_type, kick_pos)

func _on_KickTimer_timeout():
	# Falls into same shortcoming as apply_kick_damage(), but for now it's fine. 
	
	if dead:
		return
	var areas = kick_detector.get_overlapping_areas()
	if areas.size() > 0:
		# Should only ever be one overlapping area, which is the horse's hitbox
		_on_KickDetector_area_entered(areas[0])
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	# Set next timer duration for kick timer, add some randomness. 
	kick_timer.wait_time = rng.randf_range(0.25, 0.50)# + rng.randf_range(-0.2,2.0)

func _on_ReactionTimer_timeout():
	# This is a shooting function, so if dead or no ammo, do nothing
	if dead || ammo <= 0:
		return
	
	var target_dist = Global.player.global_position - global_position
	# Get the target's rotation relative to the x-axis. 
	var true_target_rot = -target_dist.angle_to(Vector2(0, 1))
	
	# Breakout targets into fixed possible values (step = PI / 2)
	target_rot = stepify(true_target_rot, PI/12)
	if abs(target_rot) < armed_vars[type]["RotLimit"] \
		&& target_dist.length() < armed_vars[type]["ViewDist"]:
		# If rotation is within the enemy's rotation limit and
		# if the target is within range
		set_anim("Motorcycle"+type+"Aim")
		# Turn to face target
		$ArmLeft.global_rotation = target_rot
		$Head.global_rotation = target_rot
		# Emit signal to Global script to run timer safely from a "permanent" scene (Global.tscn).
		# After the timer expires, the local _shoot function here will be called. 
		emit_signal("ready_to_fire", self)
	else:
		# If rotation and distance are out of bounds, do not shoot.
		set_anim("Motorcycle"+type)

