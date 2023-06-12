extends AnimatedSprite

var vel = Vector2()
var pos = Vector2()
var type = ""

func _ready():
	pass
	#set_process(true)
	
	
func init(pos, _type):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	global_rotation = rng.randi_range(-180, 180)
	
	global_position = pos

	type = _type
	if type == "gunshot":
		scale = Vector2(0.5, 0.5)
		play("gunshot")
	else:
		rng.randomize()
		var frame = rng.randi_range(0,2)
		set_frame(frame)

	


func _on_BloodEffect_animation_finished():
	if type == "gunshot":
		queue_free()
