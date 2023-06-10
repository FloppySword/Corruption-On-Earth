extends Area2D

var anim_locked = true
var type = ""
onready var anim_player = $AnimationPlayer

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
		die()

func die():
	pass
	
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
	if type == "Driver":
		if area.global_position.x > global_position.x:
			anim_lock()
			$AnimationPlayer.play("MotorcycleDriverKickLeft")
		elif area.global_position.x < global_position.x:
			anim_lock()
			$AnimationPlayer.play("MotorcycleDriverKickRight")
			
			
