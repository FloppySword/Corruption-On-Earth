extends AnimatedSprite

#var vel = Vector2()
#var pos = Vector2()
var type = ""

func _ready():
	pass
	#set_process(true)
	
	
func _initiate(pos, _type):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	global_rotation = rng.randi_range(-180, 180)
	
	global_position = pos

	type = _type
	if type == "gunshot":
		scale = Vector2(0.4, 0.4)
		play("gunshot")
	elif type == "headshot":
		scale = Vector2(0.6, 0.6)
		play("gunshot")
	elif type == "gunshot_player":
		scale = Vector2(0.7, 0.7)
		play("gunshot")
	else:
		rng.randomize()
		var frame = rng.randi_range(0,2)
		set_frame(frame)

	


func _on_BloodEffect_animation_finished():
	
	if type == "gunshot" || type == "headshot":
		queue_free()
	elif type == "gunshot_player":
		if Global.player_health <= 0:
			frame = 0
		else:
			queue_free()
	elif type == "gunshot_horse":
		if Global.playerhorse_health <= 0:
			frame = 0
		else:
			queue_free()
