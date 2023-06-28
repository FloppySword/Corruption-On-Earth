extends Area2D

var anim_locked = true
var type = ""
onready var anim_player = $AnimationPlayer
onready var kick_timer = $Detectors/KickDetector/KickTimer
onready var kick_detector = $Detectors/KickDetector
onready var muzzle = $ArmLeft/Gun/Muzzle

var BloodImpact = preload("res://scenes/level/character/BloodEffect.tscn")

var health = 100
var ammo = 19

var dead_pos = Vector2.ZERO
var vel = Vector2.ZERO

var dead = false
var initiated = false

var target_rot = 0

var armed_vars = {"Passenger":
						{"ViewDist":400,
						"RotLimit":2.55},
					"DriverArmed":
						{"ViewDist":350,
						"RotLimit":1.85}}

var vehicle = null

signal ready_to_fire
signal shoot
signal fall

#signal die

#func _ready():
#	$AnimationPlayer.play("Motorcycle"+type)



func init(pos, _type, _vehicle):
	vehicle = _vehicle
	type = _type
	global_position = pos
	if type == "Passenger":
		ammo = 19
		$Detectors/KickDetector.monitoring = false
	elif type == "DriverArmed":
		ammo = 19
	elif type == "Driver":
		ammo = 0
	#$AnimationPlayer.call_deferred("play", "Motorcycle"+type)
	anim_player.play("Motorcycle"+type)
	anim_unlock()
	
	connect("shoot", vehicle, "_rider_shoot")
	#connect("die", vehicle, "_check_for_riders")
	connect("ready_to_fire", Global, "_enemy_remote_shoot")
	connect("fall", Global, "_enemy_remote_fall")
	
func _set_initiated():
	initiated = true
	
func _physics_process(delta):
	if ammo > 0 && type in ["DriverArmed", "Passenger"] && $ArmLeft/ReactionTimer.time_left == 0:
		$ArmLeft/ReactionTimer.start()
#			var target_dist = Global.player.global_position - global_position
#			var target_rot = -target_dist.angle_to(Vector2(0, 1))
#

#			target_rot = stepify(target_rot, PI/12)
#			if abs(target_rot) < 2.55 && target_dist.length() < 250:
#				$ArmLeft.global_rotation = target_rot
#			else:
#				anim_player.play("Motorcycle"+type)
#	if dead && !"Die" in anim_player.current_animation:
#		die()
#	if type == "Passenger":
#		print(anim_player.current_animation)
	if dead:
		if dead_pos.x != 0:
			global_position.x = dead_pos.x
		global_position.y += vel.y * delta
	
func _damage(hitbox, damage, type, pos):

	var blood_impact = BloodImpact.instance()
	add_child(blood_impact)
	blood_impact.init(pos, type)
	
#	if dead && type == "Passenger":
#		anim_player.play("Die"+type+"Normal")
		
	health -= damage
	if health <= 0:
		if !dead:
#			if type == "Passenger":
#				$Head.global_rotation = 20
			die()
#	elif health < 20:
#		vehicle._bleed()

func die():
	dead = true
	anim_lock()
	anim_player.play("Die"+type+"Normal")
	
	if "Driver" in type:
		vehicle._driver_dead()
	
	
	
func fall():
	dead_pos = global_position
	vel = Global.ground_vel #+ Vector2(0, 200)
	#emit_signal("fall", self)

	
func set_anim(animation):
	if !anim_locked:
		anim_player.play(animation)
	
func anim_lock():
	anim_locked = true
	
func anim_unlock():
	anim_locked = false

	
func _shoot():
	if dead:
		return

	ammo -= 1
	
	emit_signal("shoot", target_rot, muzzle.global_position, "Enemy")
	
	anim_lock()
	anim_player.play("Shoot")
	
	
func _check_ammo():
	#print("ammo: " + str(ammo))
	if ammo <= 0:
		anim_player.play("OutOfAmmo")

#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	print(rng.randi())
	#var player_pos = Global.player.global_position
	
func set_target_force(end:bool):
	if !end:
		vehicle.target_force = Global.target_force * 5
		vehicle.separation_force = 0
	else:
		vehicle.target_force = Global.target_force
		vehicle.separation_force = Global.separation_force
		

func _on_KickDetector_area_entered(area):
	if area.is_in_group("Enemy") || dead || kick_timer.time_left > 0:
		return
	if type == "Driver":
		anim_lock()
		
		if area.global_position.x > global_position.x:
			anim_player.play("MotorcycleDriverKickLeft")
		elif area.global_position.x < global_position.x:
			anim_player.play("MotorcycleDriverKickRight")
		else:
			anim_unlock()
			
			
func apply_kick_damage():
	var areas = kick_detector.get_overlapping_areas()
	if areas.size() > 0:
		var area = areas[0]		
		var character_scene = area.owner
		var damage = 5
		var damage_type = "kick"
		var kick_pos
		var kick_padding = Vector2(2, 0)
		#print(anim_player.current_animation)
		if anim_player.current_animation == "MotorcycleDriverKickRight":
			kick_pos = $Detectors/KickDetector/LeftCollisionShape2D.global_position
			kick_pos -= kick_padding
		else:
			kick_pos = $Detectors/KickDetector/RightCollisionShape2D.global_position
			kick_pos += kick_padding
		#print(kick_pos)
		character_scene._damage(area, damage, damage_type, kick_pos)

func _on_KickTimer_timeout():
	if dead:
		return
	var areas = kick_detector.get_overlapping_areas()
	if areas.size() > 0:
		_on_KickDetector_area_entered(areas[0])
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	kick_timer.wait_time = rng.randf_range(0.25, 0.50)# + rng.randf_range(-0.2,2.0)


func _on_ReactionTimer_timeout():
	if dead:
		return
	
	var target_dist = Global.player.global_position - global_position
	var true_target_rot = -target_dist.angle_to(Vector2(0, 1))
	
	target_rot = stepify(true_target_rot, PI/12)
	if abs(target_rot) < armed_vars[type]["RotLimit"] \
		&& target_dist.length() < armed_vars[type]["ViewDist"]:
		set_anim("Motorcycle"+type+"Aim")
		#anim_player.play("Motorcycle"+type+"Aim")
		$ArmLeft.global_rotation = target_rot
		$Head.global_rotation = target_rot
		emit_signal("ready_to_fire", self)
	else:
		set_anim("Motorcycle"+type)
		#anim_player.play("Motorcycle"+type)


func _on_RateOfFire_timeout():
	pass # Replace with function body.
