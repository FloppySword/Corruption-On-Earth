extends Area2D

var anim_locked = true
var type = ""
onready var anim_player = $AnimationPlayer
onready var kick_timer = $Detectors/KickDetector/KickTimer
onready var kick_detector = $Detectors/KickDetector

var BloodImpact = preload("res://scenes/level/character/BloodEffect.tscn")

var health = 100

#func _ready():
#	$AnimationPlayer.play("Motorcycle"+type)

func init(pos, _type):
	type = _type
	global_position = pos
	if type == "Passenger":
		$Detectors/KickDetector.monitoring = false
	
	#$AnimationPlayer.call_deferred("play", "Motorcycle"+type)
	$AnimationPlayer.play("Motorcycle"+type)
	anim_locked = false
	
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
	
	$AnimationPlayer.play("Die"+type+impact_dir)
	
func fall_off():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rn = rng.randf()
	if rn > 0.5:
		$AnimationPlayer.play("Fall"+type)
	
func set_anim(animation):
	if !anim_locked:
		$AnimationPlayer.play(animation)
	
func anim_lock():
	anim_locked = true
	
func anim_unlock():
	anim_locked = false
	
func shoot():
	var player_pos = global.player.global_position
	

func _on_KickDetector_area_entered(area):
	if kick_timer.time_left > 0:
		return
	if type == "Driver":
		if area.global_position.x > global_position.x:
			anim_lock()
			$AnimationPlayer.play("MotorcycleDriverKickLeft")
		elif area.global_position.x < global_position.x:
			anim_lock()
			$AnimationPlayer.play("MotorcycleDriverKickRight")
			
			


func _on_KickTimer_timeout():
	var areas = kick_detector.get_overlapping_areas()
	if areas.size() > 0:
		_on_KickDetector_area_entered(areas[0])
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	kick_timer.wait_time = 1 + rng.randf_range(-0.2,2.0)
