extends AnimatedSprite

var vel = Vector2()
var pos = Vector2()
var type = ""

func _ready():
	pass
	#set_process(true)
	
	
func init(pos, _type):
	global_position = pos

	type = _type
	if type == "gunshot":
		play("gunshot")
	else:
		
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var frame = rng.randi_range(0,2)
		set_frame(frame)

	


func _on_BloodEffect_animation_finished():
	if type == "gunshot":
		
		queue_free()
