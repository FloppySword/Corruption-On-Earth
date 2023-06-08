extends Area2D

var anim_locked = false
var type = ""
onready var anim_player = $AnimationPlayer

#func _ready():
#	$AnimationPlayer.play("Motorcycle"+type)

func init(pos, _type):
	type = _type
	global_position = pos
	if type == "Passenger":
		$Detectors/KickDetector.monitoring = false
	
	#$AnimationPlayer.call_deferred("play", "Motorcycle"+type)
	$AnimationPlayer.queue("Motorcycle"+type)

func set_anim(animation):
	if !anim_locked:
		$AnimationPlayer.play(animation)
	
func anim_lock():
	anim_locked = true
	
func anim_unlock():
	anim_locked = false


func _on_KickDetector_area_entered(area):
	#print("working")
	if area.global_position.x > global_position.x:
		anim_lock()
		$AnimationPlayer.play("MotorcycleKickLeft")
	elif area.global_position.x < global_position.x:
		anim_lock()
		$AnimationPlayer.play("MotorcycleKickRight")
