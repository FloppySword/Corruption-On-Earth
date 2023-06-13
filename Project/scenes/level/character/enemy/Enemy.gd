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

var target_rot = 0

var armed_vars = {"Passenger":
						{"ViewDist":300,
						"RotLimit":2.55},
					"DriverArmed":
						{"ViewDist":150,
						"RotLimit":1.75}}

var vehicle = null

signal ready_to_fire
signal  shoot

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
	
	connect("ready_to_fire", global, "_enemy_remote_shoot")
	
func _physics_process(delta):
	if ammo > 0 && type in ["DriverArmed", "Passenger"] && $ArmLeft/ReactionTimer.time_left == 0:
		$ArmLeft/ReactionTimer.start()
#			var target_dist = global.player.global_position - global_position
#			var target_rot = -target_dist.angle_to(Vector2(0, 1))
#

#			target_rot = stepify(target_rot, PI/12)
#			if abs(target_rot) < 2.55 && target_dist.length() < 250:
#				$ArmLeft.global_rotation = target_rot
#			else:
#				anim_player.play("Motorcycle"+type)
	
func _damage(hitbox, damage, type, pos):
	if type == "gunshot":
		var blood_impact = BloodImpact.instance()
		add_child(blood_impact)
		blood_impact.init(pos, type)
		
	health -= damage
	if health <= 0:
		die(pos)

func die(pos):
	var impact_dir = ""
	if abs(pos.x - global_position.x) < 20:
		impact_dir = "Normal"
	else:
		if pos.x > global_position.x:
			impact_dir = "Right"
		else:
			impact_dir = "Left"
	anim_lock()
	anim_player.play("Die"+type+impact_dir)
	
func fall_off():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rn = rng.randf()
	if rn > 0.5:
		
		anim_player.play("Fall"+type)
		#$AnimationPlayer.play("Fall"+type)
	
func set_anim(animation):
	if !anim_locked:
		anim_player.play(animation)
	
func anim_lock():
	anim_locked = true
	
func anim_unlock():
	anim_locked = false
	
func _shoot():
	ammo -= 1
	
	emit_signal("shoot", target_rot, muzzle.global_position)
	
	anim_lock()
	anim_player.play("Shoot")
	
	
func _check_ammo():
	if ammo <= 0:
		anim_player.play("OutOfAmmo")

#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	print(rng.randi())
	#var player_pos = global.player.global_position
	
	

func _on_KickDetector_area_entered(area):
	if kick_timer.time_left > 0:
		return
	if type == "Driver":
		anim_lock()
		if area.global_position.x > global_position.x:

			anim_player.play("MotorcycleDriverKickLeft")
		elif area.global_position.x < global_position.x:
			
			anim_player.play("MotorcycleDriverKickRight")
		else:
			anim_unlock()
			
			


func _on_KickTimer_timeout():
	var areas = kick_detector.get_overlapping_areas()
	if areas.size() > 0:
		_on_KickDetector_area_entered(areas[0])
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	kick_timer.wait_time = 1 + rng.randf_range(-0.2,2.0)


func _on_ReactionTimer_timeout():
	var target_dist = global.player.global_position - global_position
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
